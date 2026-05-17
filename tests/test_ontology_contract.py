import hashlib
import json
import re
import shutil
import tempfile
import tomllib
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

from tools.wendao_audio_claim_acceptance.__main__ import build_acceptance_report
from tools.wendao_audio_claim_rdf_preview.__main__ import build_rdf_patch_preview
from tools.wendao_audio_claim_rdf_source_promotion.__main__ import (
    build_source_promotion_proposal,
)
from tools.wendao_audio_claim_rdf_staged_apply.__main__ import (
    build_staged_apply_report,
)
from tools.wendao_audio_claim_rdf_source_edit_preflight.__main__ import (
    build_source_edit_preflight_report,
)
from tools.wendao_audio_claim_rdf_source_edit_gate.__main__ import (
    build_source_edit_gate_report,
)
from tools.wendao_audio_claim_rdf_source_apply.__main__ import (
    build_source_apply_report,
)
from tools.wendao_audio_claim_rdf_source_apply_verification.__main__ import (
    build_source_apply_verification_report,
)
from tools.wendao_audio_claim_rdf_pipeline_receipt.__main__ import (
    build_pipeline_receipt,
)
from tools.wendao_dataset_ontology.__main__ import (
    build_validation_report,
    emit_raw_table_arrow_ipc,
    load_mapping_contract,
    read_raw_table_arrow_ipc_counts,
    validate_contract_references,
)
from tools.wendao_ontology_registry.__main__ import build_registry, registry_text


EPISTEME_ROOT = Path(__file__).resolve().parents[1]
ONTOLOGY_ROOT = EPISTEME_ROOT / "ontology"
RDF_NS = "{http://www.w3.org/1999/02/22-rdf-syntax-ns#}"
RDFS_NS = "{http://www.w3.org/2000/01/rdf-schema#}"
OWL_NS = "{http://www.w3.org/2002/07/owl#}"
FORBIDDEN_SQL_OPERATIONS = {
    "CREATE",
    "ALTER",
    "DROP",
    "INSERT",
    "UPDATE",
    "DELETE",
    "MERGE",
    "COPY",
    "ATTACH",
}


def load_manifest() -> dict:
    return tomllib.loads((ONTOLOGY_ROOT / "manifest.toml").read_text())


def load_api_surface(manifest: dict | None = None) -> dict:
    if manifest is None:
        manifest = load_manifest()
    return tomllib.loads((ONTOLOGY_ROOT / manifest["api_surface"]["file"]).read_text())


def strip_sql_comments_and_literals(sql: str) -> str:
    without_line_comments = re.sub(r"--.*?$", " ", sql, flags=re.MULTILINE)
    without_block_comments = re.sub(r"/\*.*?\*/", " ", without_line_comments, flags=re.DOTALL)
    return re.sub(r"'(?:''|[^'])*'", "''", without_block_comments)


def collect_rdf_terms(manifest: dict) -> dict[str, dict[str, dict[str, str | None]]]:
    terms: dict[str, dict[str, dict[str, str | None]]] = {
        "classes": {},
        "object_properties": {},
    }

    for domain in manifest["domains"]:
        for relative_path in domain.get("rdf_files", []):
            tree = ET.parse(ONTOLOGY_ROOT / relative_path)
            root = tree.getroot()

            for class_node in root.findall(f"{OWL_NS}Class"):
                rdf_about = class_node.attrib.get(f"{RDF_NS}about")
                if rdf_about:
                    terms["classes"][rdf_about] = {"domain": domain["id"]}

            for property_node in root.findall(f"{OWL_NS}ObjectProperty"):
                rdf_about = property_node.attrib.get(f"{RDF_NS}about")
                if not rdf_about:
                    continue
                domain_node = property_node.find(f"{RDFS_NS}domain")
                range_node = property_node.find(f"{RDFS_NS}range")
                terms["object_properties"][rdf_about] = {
                    "domain": domain["id"],
                    "from": (
                        domain_node.attrib.get(f"{RDF_NS}resource")
                        if domain_node is not None
                        else None
                    ),
                    "to": (
                        range_node.attrib.get(f"{RDF_NS}resource")
                        if range_node is not None
                        else None
                    ),
                }

    return terms


def assert_unique_api_names(test_case: unittest.TestCase, entries: list[dict], label: str):
    api_names = [entry["api_name"] for entry in entries]
    test_case.assertEqual(
        len(api_names),
        len(set(api_names)),
        f"duplicate {label} api_name values",
    )


class OntologyContractTests(unittest.TestCase):
    def test_manifest_declared_files_exist(self):
        manifest = load_manifest()

        for domain in manifest["domains"]:
            for key in ("rdf_files", "rules", "policies", "dataset_mappings"):
                for relative_path in domain.get(key, []):
                    path = ONTOLOGY_ROOT / relative_path
                    self.assertTrue(path.is_file(), f"missing {key} entry: {relative_path}")

    def test_manifest_declared_rdf_files_parse_as_xml(self):
        manifest = load_manifest()

        for domain in manifest["domains"]:
            for relative_path in domain.get("rdf_files", []):
                with self.subTest(rdf=relative_path):
                    ET.parse(ONTOLOGY_ROOT / relative_path)

    def test_extension_example_extends_known_domain(self):
        manifest = load_manifest()
        known_domains = {domain["id"] for domain in manifest["domains"]}
        example_path = ONTOLOGY_ROOT / manifest["extension_contract"]["example"]
        example = tomllib.loads(example_path.read_text())

        extends = example["ontology"]["metadata"]["extends"]
        namespace = example["ontology"]["metadata"]["namespace"]

        self.assertIn(extends, known_domains)
        self.assertRegex(namespace, r"^[A-Za-z][A-Za-z0-9_]*$")
        self.assertGreaterEqual(len(example.get("entity", [])), 1)
        self.assertGreaterEqual(len(example.get("relation", [])), 1)

    def test_extension_mounts_rules_for_extends_domain_only(self):
        manifest = load_manifest()
        example = tomllib.loads(
            (ONTOLOGY_ROOT / manifest["extension_contract"]["example"]).read_text()
        )
        extends = example["ontology"]["metadata"]["extends"]

        mounted_domains = [domain for domain in manifest["domains"] if domain["id"] == extends]

        self.assertEqual(len(mounted_domains), 1)
        self.assertTrue(mounted_domains[0].get("rules"))
        self.assertTrue(
            all(rule.startswith("10_Software_Engineering/rules/") for rule in mounted_domains[0]["rules"])
        )

    def test_sql_rules_are_select_only_source_artifacts(self):
        manifest = load_manifest()
        rule_paths = [
            ONTOLOGY_ROOT / rule
            for domain in manifest["domains"]
            for rule in domain.get("rules", [])
        ]

        self.assertGreaterEqual(len(rule_paths), 1)
        for path in rule_paths:
            with self.subTest(sql=path.relative_to(ONTOLOGY_ROOT)):
                sql = strip_sql_comments_and_literals(path.read_text())
                forbidden = FORBIDDEN_SQL_OPERATIONS.intersection(
                    match.group(0).upper()
                    for match in re.finditer(r"\b[A-Za-z]+\b", sql)
                )
                self.assertFalse(forbidden, f"forbidden SQL operations in {path}: {forbidden}")

    def test_api_surface_manifest_entry_exists(self):
        manifest = load_manifest()
        api_surface_path = ONTOLOGY_ROOT / manifest["api_surface"]["file"]

        self.assertTrue(api_surface_path.is_file())
        self.assertEqual(manifest["api_surface"]["compatibility"], "semantic_api_compatibility")
        self.assertIn("OntologyObject", manifest["api_surface"]["reference_nouns"])
        self.assertIn("Action", manifest["api_surface"]["reference_nouns"])
        self.assertIn("Query", manifest["api_surface"]["reference_nouns"])
        self.assertIn("OntologyInterface", manifest["api_surface"]["reference_nouns"])

    def test_audio_claim_acceptance_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_acceptance"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(contract["runtime_proposal_owner"], "xiuxian-wendao")
        self.assertEqual(contract["acceptance_state"], "accepted_for_source_contract_review")
        self.assertFalse(contract["rdf_materialization_allowed"])
        self.assertFalse(contract["ontology_source_write_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"] / "claims.tsv").is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"] / "receipt.json").is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"] / "acceptance_report.json").is_file())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["rdf_materialization_performed"]["const"], False)
        self.assertEqual(schema["properties"]["ontology_source_write_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)

    def test_audio_claim_rdf_preview_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_rdf_preview"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(contract["acceptance_contract"], "audio_claim_acceptance")
        self.assertFalse(contract["rdf_source_write_allowed"])
        self.assertFalse(contract["ontology_truth_promotion_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"]).is_file())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["rdf_source_write_performed"]["const"], False)
        self.assertEqual(schema["properties"]["ontology_truth_promotion_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)

    def test_audio_claim_rdf_source_promotion_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_rdf_source_promotion"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(contract["preview_contract"], "audio_claim_rdf_preview")
        self.assertFalse(contract["rdf_source_write_allowed"])
        self.assertFalse(contract["ontology_truth_promotion_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["review_decision"]).is_file())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["rdf_source_write_performed"]["const"], False)
        self.assertEqual(schema["properties"]["ontology_truth_promotion_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)

    def test_audio_claim_rdf_staged_apply_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_rdf_staged_apply"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(contract["source_promotion_contract"], "audio_claim_rdf_source_promotion")
        self.assertFalse(contract["canonical_source_write_allowed"])
        self.assertFalse(contract["ontology_truth_promotion_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["staged_output"]).is_dir())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["canonical_source_write_performed"]["const"], False)
        self.assertEqual(schema["properties"]["ontology_truth_promotion_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)

    def test_audio_claim_rdf_source_edit_preflight_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_rdf_source_edit_preflight"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(contract["staged_apply_contract"], "audio_claim_rdf_staged_apply")
        self.assertFalse(contract["canonical_source_write_allowed"])
        self.assertFalse(contract["ontology_truth_promotion_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["diff_output"]).is_dir())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["canonical_source_write_performed"]["const"], False)
        self.assertEqual(schema["properties"]["ontology_truth_promotion_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)

    def test_audio_claim_rdf_source_edit_gate_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_rdf_source_edit_gate"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(contract["source_edit_preflight_contract"], "audio_claim_rdf_source_edit_preflight")
        self.assertFalse(contract["canonical_source_write_allowed"])
        self.assertFalse(contract["ontology_truth_promotion_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["source_edit_decision"]).is_file())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["canonical_source_write_performed"]["const"], False)
        self.assertEqual(schema["properties"]["ontology_truth_promotion_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)
        self.assertEqual(schema["properties"]["manual_source_edit_required"]["const"], True)

    def test_audio_claim_rdf_source_apply_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_rdf_source_apply"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(contract["source_edit_gate_contract"], "audio_claim_rdf_source_edit_gate")
        self.assertTrue(contract["canonical_source_write_allowed"])
        self.assertFalse(contract["default_canonical_source_write"])
        self.assertFalse(contract["ontology_truth_promotion_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"]).is_file())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["ontology_truth_promotion_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)

    def test_audio_claim_rdf_source_apply_verification_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_rdf_source_apply_verification"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(contract["source_apply_contract"], "audio_claim_rdf_source_apply")
        self.assertFalse(contract["canonical_source_write_allowed"])
        self.assertFalse(contract["ontology_truth_promotion_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"]).is_file())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["ontology_truth_promotion_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)

    def test_audio_claim_rdf_pipeline_receipt_contract_is_declared(self):
        manifest = load_manifest()
        contract = manifest["audio_claim_rdf_pipeline_receipt"]

        self.assertEqual(contract["owner"], "wendao-episteme")
        self.assertEqual(
            contract["source_apply_verification_contract"],
            "audio_claim_rdf_source_apply_verification",
        )
        self.assertFalse(contract["canonical_source_write_allowed"])
        self.assertFalse(contract["ontology_truth_promotion_allowed"])
        self.assertFalse(contract["raw_transcript_text_allowed"])
        self.assertTrue((ONTOLOGY_ROOT / contract["schema"]).is_file())
        self.assertTrue((ONTOLOGY_ROOT / contract["example"]).is_file())

        schema = json.loads((ONTOLOGY_ROOT / contract["schema"]).read_text())
        self.assertEqual(schema["properties"]["ontology_truth_promotion_performed"]["const"], False)
        self.assertEqual(schema["properties"]["raw_transcript_text_included"]["const"], False)

    def test_api_surface_references_known_rdf_terms_and_rules(self):
        manifest = load_manifest()
        api_surface = load_api_surface(manifest)
        terms = collect_rdf_terms(manifest)
        known_domains = {domain["id"] for domain in manifest["domains"]}
        known_rules = {
            rule
            for domain in manifest["domains"]
            for rule in domain.get("rules", [])
        }
        object_types = {
            object_type["api_name"]: object_type
            for object_type in api_surface["object_types"]
        }

        assert_unique_api_names(self, api_surface["object_types"], "object type")
        assert_unique_api_names(self, api_surface["link_types"], "link type")
        assert_unique_api_names(self, api_surface["action_types"], "action type")
        assert_unique_api_names(self, api_surface["query_types"], "query type")
        assert_unique_api_names(self, api_surface["interface_types"], "interface type")

        for object_type in api_surface["object_types"]:
            with self.subTest(object_type=object_type["api_name"]):
                self.assertIn(object_type["domain"], known_domains)
                self.assertIn(object_type["rdf_class"], terms["classes"])
                self.assertGreaterEqual(len(object_type["primary_key"]), 1)
                self.assertRegex(object_type["api_name"], r"^[A-Z][A-Za-z0-9]*$")

        for link_type in api_surface["link_types"]:
            with self.subTest(link_type=link_type["api_name"]):
                self.assertIn(link_type["domain"], known_domains)
                self.assertIn(link_type["rdf_property"], terms["object_properties"])
                self.assertIn(link_type["from_object_type"], object_types)
                self.assertIn(link_type["to_object_type"], object_types)
                self.assertIn(
                    link_type["cardinality"],
                    {"one_to_one", "one_to_many", "many_to_one", "many_to_many"},
                )

                rdf_property = terms["object_properties"][link_type["rdf_property"]]
                from_class = object_types[link_type["from_object_type"]]["rdf_class"]
                to_class = object_types[link_type["to_object_type"]]["rdf_class"]
                self.assertEqual(rdf_property["from"], from_class)
                self.assertEqual(rdf_property["to"], to_class)

        for action_type in api_surface["action_types"]:
            with self.subTest(action_type=action_type["api_name"]):
                self.assertIn(action_type["domain"], known_domains)
                self.assertRegex(action_type["api_name"], r"^[a-z][A-Za-z0-9]*$")
                self.assertGreaterEqual(len(action_type["affected_object_types"]), 1)
                for affected_object_type in action_type["affected_object_types"]:
                    self.assertIn(affected_object_type, object_types)
                for rule in action_type["validation_rules"]:
                    self.assertIn(rule, known_rules)
                self.assertIs(type(action_type["requires_evidence"]), bool)

        for query_type in api_surface["query_types"]:
            with self.subTest(query_type=query_type["api_name"]):
                self.assertIn(query_type["domain"], known_domains)
                self.assertRegex(query_type["api_name"], r"^[a-z][A-Za-z0-9]*$")
                self.assertGreaterEqual(len(query_type["parameters"]), 1)
                self.assertIn(query_type["returns"], object_types)

        for interface_type in api_surface["interface_types"]:
            with self.subTest(interface_type=interface_type["api_name"]):
                self.assertRegex(interface_type["api_name"], r"^[A-Z][A-Za-z0-9]*$")
                self.assertGreaterEqual(len(interface_type["implemented_by"]), 1)
                for object_type in interface_type["implemented_by"]:
                    self.assertIn(object_type, object_types)

    def test_api_surface_covers_healthcare_and_finance_verticals(self):
        api_surface = load_api_surface()
        required_domains = {
            "episteme://30_Healthcare": "Healthcare",
            "episteme://20_Commercial_Finance": "Commercial Finance",
        }

        for domain_id, label in required_domains.items():
            with self.subTest(domain=label):
                self.assertGreaterEqual(
                    sum(1 for item in api_surface["object_types"] if item["domain"] == domain_id),
                    2,
                )
                self.assertGreaterEqual(
                    sum(1 for item in api_surface["link_types"] if item["domain"] == domain_id),
                    1,
                )
                self.assertGreaterEqual(
                    sum(1 for item in api_surface["action_types"] if item["domain"] == domain_id),
                    1,
                )
                self.assertGreaterEqual(
                    sum(1 for item in api_surface["query_types"] if item["domain"] == domain_id),
                    1,
                )

    def test_ontology_registry_snapshot_is_current(self):
        registry_path = ONTOLOGY_ROOT / "registry.json"
        registry = build_registry()

        self.assertEqual(registry_path.read_text(), registry_text(registry))
        self.assertEqual(registry["schema_version"], 1)
        self.assertEqual(registry["ontology"], "wendao")
        self.assertIn("OntologyObject", registry["reference_nouns"])
        self.assertGreaterEqual(len(registry["rdf_terms"]["classes"]), 1)
        self.assertGreaterEqual(len(registry["api"]["object_types"]), 1)
        self.assertGreaterEqual(len(registry["dataset_mappings"]), 1)
        self.assertEqual(
            registry["audio_claim_acceptance"],
            {
                "schema": "audio_claim_acceptance.schema.json",
                "example": "examples/audio_claim_promotion_proposal",
                "owner": "wendao-episteme",
                "runtime_proposal_owner": "xiuxian-wendao",
                "acceptance_state": "accepted_for_source_contract_review",
                "rdf_materialization_allowed": False,
                "ontology_source_write_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )
        self.assertEqual(
            registry["audio_claim_rdf_source_promotion"],
            {
                "schema": "audio_claim_rdf_source_promotion.schema.json",
                "example": "examples/audio_claim_promotion_proposal/rdf_source_promotion_proposal.json",
                "review_decision": "examples/audio_claim_promotion_proposal/source_review_decision.json",
                "owner": "wendao-episteme",
                "preview_contract": "audio_claim_rdf_preview",
                "rdf_source_write_allowed": False,
                "ontology_truth_promotion_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )
        self.assertEqual(
            registry["audio_claim_rdf_staged_apply"],
            {
                "schema": "audio_claim_rdf_staged_apply.schema.json",
                "example": "examples/audio_claim_promotion_proposal/rdf_staged_apply/report.json",
                "staged_output": "examples/audio_claim_promotion_proposal/rdf_staged_apply",
                "owner": "wendao-episteme",
                "source_promotion_contract": "audio_claim_rdf_source_promotion",
                "canonical_source_write_allowed": False,
                "ontology_truth_promotion_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )
        self.assertEqual(
            registry["audio_claim_rdf_source_edit_preflight"],
            {
                "schema": "audio_claim_rdf_source_edit_preflight.schema.json",
                "example": "examples/audio_claim_promotion_proposal/rdf_source_edit_preflight/report.json",
                "diff_output": "examples/audio_claim_promotion_proposal/rdf_source_edit_preflight",
                "owner": "wendao-episteme",
                "staged_apply_contract": "audio_claim_rdf_staged_apply",
                "canonical_source_write_allowed": False,
                "ontology_truth_promotion_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )
        self.assertEqual(
            registry["audio_claim_rdf_source_edit_gate"],
            {
                "schema": "audio_claim_rdf_source_edit_gate.schema.json",
                "example": "examples/audio_claim_promotion_proposal/rdf_source_edit_gate/report.json",
                "source_edit_decision": "examples/audio_claim_promotion_proposal/source_edit_decision.json",
                "owner": "wendao-episteme",
                "source_edit_preflight_contract": "audio_claim_rdf_source_edit_preflight",
                "canonical_source_write_allowed": False,
                "ontology_truth_promotion_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )
        self.assertEqual(
            registry["audio_claim_rdf_source_apply"],
            {
                "schema": "audio_claim_rdf_source_apply.schema.json",
                "example": "examples/audio_claim_promotion_proposal/rdf_source_apply/report.json",
                "owner": "wendao-episteme",
                "source_edit_gate_contract": "audio_claim_rdf_source_edit_gate",
                "canonical_source_write_allowed": True,
                "default_canonical_source_write": False,
                "ontology_truth_promotion_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )
        self.assertEqual(
            registry["audio_claim_rdf_source_apply_verification"],
            {
                "schema": "audio_claim_rdf_source_apply_verification.schema.json",
                "example": "examples/audio_claim_promotion_proposal/rdf_source_apply_verification/report.json",
                "owner": "wendao-episteme",
                "source_apply_contract": "audio_claim_rdf_source_apply",
                "canonical_source_write_allowed": False,
                "ontology_truth_promotion_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )
        self.assertEqual(
            registry["audio_claim_rdf_pipeline_receipt"],
            {
                "schema": "audio_claim_rdf_pipeline_receipt.schema.json",
                "example": "examples/audio_claim_promotion_proposal/rdf_pipeline_receipt.json",
                "owner": "wendao-episteme",
                "source_apply_verification_contract": "audio_claim_rdf_source_apply_verification",
                "canonical_source_write_allowed": False,
                "ontology_truth_promotion_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )
        self.assertEqual(
            registry["audio_claim_rdf_preview"],
            {
                "schema": "audio_claim_rdf_preview.schema.json",
                "example": "examples/audio_claim_promotion_proposal/rdf_patch_preview.json",
                "owner": "wendao-episteme",
                "acceptance_contract": "audio_claim_acceptance",
                "rdf_source_write_allowed": False,
                "ontology_truth_promotion_allowed": False,
                "raw_transcript_text_allowed": False,
            },
        )

    def test_audio_claim_acceptance_fixture_passes_without_rdf_or_raw_text(self):
        manifest = load_manifest()
        proposal_dir = ONTOLOGY_ROOT / manifest["audio_claim_acceptance"]["example"]
        report = build_acceptance_report(proposal_dir)

        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["acceptance_state"], "accepted_for_source_contract_review")
        self.assertEqual(report["claim_count"], 1)
        self.assertEqual(report["evidence_segment_count"], 1)
        self.assertEqual(report["known_predicate_count"], 1)
        self.assertFalse(report["rdf_materialization_performed"])
        self.assertFalse(report["ontology_source_write_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        self.assertNotIn("raw transcript content marker", "\n".join(report["errors"]))
        expected = json.loads((proposal_dir / "acceptance_report.json").read_text())
        self.assertEqual(report, expected)

    def test_audio_claim_acceptance_rejects_unknown_predicate(self):
        manifest = load_manifest()
        source_dir = ONTOLOGY_ROOT / manifest["audio_claim_acceptance"]["example"]
        with tempfile.TemporaryDirectory() as temp_dir:
            proposal_dir = Path(temp_dir) / "proposal"
            shutil.copytree(source_dir, proposal_dir)
            claims_path = proposal_dir / "claims.tsv"
            claims_path.write_text(
                claims_path.read_text().replace(
                    "https://wendao.ai/ontology/core#basedOn",
                    "https://wendao.ai/ontology/unknown#unsupported",
                )
            )

            report = build_acceptance_report(proposal_dir)

        self.assertFalse(report["passed"])
        self.assertEqual(report["acceptance_state"], "rejected")
        self.assertIn(
            "ontology_predicate is not a known RDF object property",
            "\n".join(report["errors"]),
        )

    def test_audio_claim_rdf_preview_fixture_is_current_without_mutation(self):
        manifest = load_manifest()
        acceptance_contract = manifest["audio_claim_acceptance"]
        preview_contract = manifest["audio_claim_rdf_preview"]
        proposal_dir = ONTOLOGY_ROOT / acceptance_contract["example"]

        report = build_rdf_patch_preview(proposal_dir)

        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["preview_state"], "preview_ready")
        self.assertEqual(report["patch_count"], 1)
        self.assertFalse(report["rdf_source_write_performed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        self.assertEqual(len(report["patches"]), report["patch_count"])
        patch_payload = json.dumps(report["patches"])
        self.assertNotIn("raw_transcript", patch_payload)
        self.assertNotIn("transcript_text", patch_payload)
        ET.fromstring(report["patches"][0]["rdf_xml_preview"])

        expected = json.loads((ONTOLOGY_ROOT / preview_contract["example"]).read_text())
        self.assertEqual(report, expected)
        self.assertEqual(Path(preview_contract["example"]).suffix, ".json")

    def test_audio_claim_rdf_preview_rejects_failed_acceptance(self):
        manifest = load_manifest()
        source_dir = ONTOLOGY_ROOT / manifest["audio_claim_acceptance"]["example"]
        with tempfile.TemporaryDirectory() as temp_dir:
            proposal_dir = Path(temp_dir) / "proposal"
            shutil.copytree(source_dir, proposal_dir)
            claims_path = proposal_dir / "claims.tsv"
            claims_path.write_text(
                claims_path.read_text().replace(
                    "https://wendao.ai/ontology/core#basedOn",
                    "https://wendao.ai/ontology/unknown#unsupported",
                )
            )

            report = build_rdf_patch_preview(proposal_dir)

        self.assertFalse(report["passed"])
        self.assertEqual(report["preview_state"], "rejected")
        self.assertEqual(report["patch_count"], 0)
        self.assertEqual(report["patches"], [])
        self.assertFalse(report["rdf_source_write_performed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        self.assertIn(
            "ontology_predicate is not a known RDF object property",
            "\n".join(report["errors"]),
        )

    def test_audio_claim_rdf_source_promotion_fixture_is_current_without_mutation(self):
        manifest = load_manifest()
        acceptance_contract = manifest["audio_claim_acceptance"]
        promotion_contract = manifest["audio_claim_rdf_source_promotion"]
        proposal_dir = ONTOLOGY_ROOT / acceptance_contract["example"]
        review_decision_path = ONTOLOGY_ROOT / promotion_contract["review_decision"]
        target_rdf_path = ONTOLOGY_ROOT / "00_Core_Primitives/00.03_action.rdf"
        before_hash = sha256_file(target_rdf_path)

        report = build_source_promotion_proposal(proposal_dir, review_decision_path)
        after_hash = sha256_file(target_rdf_path)

        self.assertEqual(before_hash, after_hash)
        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["source_promotion_state"], "ready_for_source_patch")
        self.assertEqual(report["patch_count"], 1)
        self.assertFalse(report["rdf_source_write_performed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        self.assertEqual(
            report["target_files"],
            [
                {
                    "path": "00_Core_Primitives/00.03_action.rdf",
                    "precondition_sha256": before_hash,
                }
            ],
        )
        self.assertEqual(report["patches"][0]["target_file_precondition_sha256"], before_hash)
        self.assertEqual(report["patches"][0]["insert_before"], "</rdf:RDF>")
        ET.fromstring(report["patches"][0]["rdf_xml_preview"])
        patch_payload = json.dumps(report["patches"])
        self.assertNotIn("raw_transcript", patch_payload)
        self.assertNotIn("transcript_text", patch_payload)

        expected = json.loads((ONTOLOGY_ROOT / promotion_contract["example"]).read_text())
        self.assertEqual(report, expected)
        self.assertEqual(Path(promotion_contract["example"]).suffix, ".json")

    def test_audio_claim_rdf_source_promotion_requires_approved_review(self):
        manifest = load_manifest()
        source_dir = ONTOLOGY_ROOT / manifest["audio_claim_acceptance"]["example"]
        with tempfile.TemporaryDirectory() as temp_dir:
            proposal_dir = Path(temp_dir) / "proposal"
            shutil.copytree(source_dir, proposal_dir)
            decision_path = proposal_dir / "source_review_decision.json"
            decision = json.loads(decision_path.read_text())
            decision["review_state"] = "rejected_by_source_reviewer"
            decision_path.write_text(json.dumps(decision, indent=2, sort_keys=True) + "\n")

            report = build_source_promotion_proposal(proposal_dir, decision_path)

        self.assertFalse(report["passed"])
        self.assertEqual(report["source_promotion_state"], "rejected")
        self.assertEqual(report["patch_count"], 0)
        self.assertEqual(report["target_files"], [])
        self.assertIn(
            "review decision must approve source patch proposal generation",
            "\n".join(report["errors"]),
        )

    def test_audio_claim_rdf_source_promotion_rejects_failed_preview(self):
        manifest = load_manifest()
        source_dir = ONTOLOGY_ROOT / manifest["audio_claim_acceptance"]["example"]
        with tempfile.TemporaryDirectory() as temp_dir:
            proposal_dir = Path(temp_dir) / "proposal"
            shutil.copytree(source_dir, proposal_dir)
            claims_path = proposal_dir / "claims.tsv"
            claims_path.write_text(
                claims_path.read_text().replace(
                    "https://wendao.ai/ontology/core#basedOn",
                    "https://wendao.ai/ontology/unknown#unsupported",
                )
            )

            report = build_source_promotion_proposal(
                proposal_dir,
                proposal_dir / "source_review_decision.json",
            )

        self.assertFalse(report["passed"])
        self.assertEqual(report["source_promotion_state"], "rejected")
        self.assertEqual(report["patch_count"], 0)
        self.assertEqual(report["patches"], [])
        self.assertIn(
            "ontology_predicate is not a known RDF object property",
            "\n".join(report["errors"]),
        )

    def test_audio_claim_rdf_staged_apply_fixture_is_current_without_source_overwrite(self):
        manifest = load_manifest()
        staged_contract = manifest["audio_claim_rdf_staged_apply"]
        promotion_contract = manifest["audio_claim_rdf_source_promotion"]
        source_promotion_path = ONTOLOGY_ROOT / promotion_contract["example"]
        staged_output = ONTOLOGY_ROOT / staged_contract["staged_output"]
        target_rdf_path = ONTOLOGY_ROOT / "00_Core_Primitives/00.03_action.rdf"
        before_hash = sha256_file(target_rdf_path)

        report = build_staged_apply_report(source_promotion_path, staged_output)
        after_hash = sha256_file(target_rdf_path)

        self.assertEqual(before_hash, after_hash)
        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["staged_apply_state"], "staged")
        self.assertEqual(report["staged_file_count"], 1)
        self.assertFalse(report["canonical_source_write_performed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        staged_rdf_path = ONTOLOGY_ROOT / report["staged_files"][0]["staged_rdf_file"]
        self.assertTrue(staged_rdf_path.is_file())
        self.assertNotEqual(sha256_file(staged_rdf_path), before_hash)
        ET.parse(staged_rdf_path)
        self.assertIn("staged audio claim patch", staged_rdf_path.read_text())
        self.assertNotIn("staged audio claim patch", target_rdf_path.read_text())

        expected = json.loads((ONTOLOGY_ROOT / staged_contract["example"]).read_text())
        self.assertEqual(report, expected)
        self.assertEqual(Path(staged_contract["example"]).suffix, ".json")

    def test_audio_claim_rdf_staged_apply_rejects_precondition_mismatch(self):
        manifest = load_manifest()
        source_path = ONTOLOGY_ROOT / manifest["audio_claim_rdf_source_promotion"]["example"]
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            proposal_path = temp_root / "rdf_source_promotion_proposal.json"
            proposal = json.loads(source_path.read_text())
            bad_hash = "sha256:" + "0" * 64
            proposal["target_files"][0]["precondition_sha256"] = bad_hash
            proposal["patches"][0]["target_file_precondition_sha256"] = bad_hash
            proposal_path.write_text(json.dumps(proposal, indent=2, sort_keys=True) + "\n")
            output_dir = temp_root / "staged"

            report = build_staged_apply_report(
                proposal_path,
                output_dir,
                write_artifacts=True,
            )

        self.assertFalse(report["passed"])
        self.assertEqual(report["staged_apply_state"], "rejected")
        self.assertEqual(report["staged_file_count"], 0)
        self.assertEqual(report["staged_files"], [])
        self.assertIn("precondition mismatch", "\n".join(report["errors"]))

    def test_audio_claim_rdf_source_edit_preflight_fixture_is_current_without_source_overwrite(self):
        manifest = load_manifest()
        preflight_contract = manifest["audio_claim_rdf_source_edit_preflight"]
        staged_contract = manifest["audio_claim_rdf_staged_apply"]
        staged_report_path = ONTOLOGY_ROOT / staged_contract["example"]
        diff_output = ONTOLOGY_ROOT / preflight_contract["diff_output"]
        target_rdf_path = ONTOLOGY_ROOT / "00_Core_Primitives/00.03_action.rdf"
        before_hash = sha256_file(target_rdf_path)

        report = build_source_edit_preflight_report(staged_report_path, diff_output)
        after_hash = sha256_file(target_rdf_path)

        self.assertEqual(before_hash, after_hash)
        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["source_edit_preflight_state"], "diff_ready")
        self.assertEqual(report["diff_file_count"], 1)
        self.assertFalse(report["canonical_source_write_performed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        diff_path = ONTOLOGY_ROOT / report["diff_files"][0]["diff_file"]
        self.assertTrue(diff_path.is_file())
        diff_text = diff_path.read_text()
        self.assertIn("+  <!-- staged audio claim patch: audio-reviewed-claim-001 -->", diff_text)
        self.assertNotIn("staged audio claim patch", target_rdf_path.read_text())
        self.assertEqual(report["diff_files"][0]["source_sha256"], before_hash)
        self.assertEqual(report["diff_files"][0]["diff_sha256"], sha256_file(diff_path))

        expected = json.loads((ONTOLOGY_ROOT / preflight_contract["example"]).read_text())
        self.assertEqual(report, expected)
        self.assertEqual(Path(preflight_contract["example"]).suffix, ".json")

    def test_audio_claim_rdf_source_edit_preflight_rejects_staged_hash_mismatch(self):
        manifest = load_manifest()
        staged_report_path = ONTOLOGY_ROOT / manifest["audio_claim_rdf_staged_apply"]["example"]
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            report_path = temp_root / "report.json"
            staged_report = json.loads(staged_report_path.read_text())
            staged_report["staged_files"][0]["staged_sha256"] = "sha256:" + "0" * 64
            report_path.write_text(json.dumps(staged_report, indent=2, sort_keys=True) + "\n")
            output_dir = temp_root / "preflight"

            report = build_source_edit_preflight_report(
                report_path,
                output_dir,
                write_artifacts=True,
            )

        self.assertFalse(report["passed"])
        self.assertEqual(report["source_edit_preflight_state"], "rejected")
        self.assertEqual(report["diff_file_count"], 0)
        self.assertEqual(report["diff_files"], [])
        self.assertIn("staged hash mismatch", "\n".join(report["errors"]))

    def test_audio_claim_rdf_source_edit_gate_fixture_is_current_without_source_overwrite(self):
        manifest = load_manifest()
        gate_contract = manifest["audio_claim_rdf_source_edit_gate"]
        preflight_contract = manifest["audio_claim_rdf_source_edit_preflight"]
        preflight_report_path = ONTOLOGY_ROOT / preflight_contract["example"]
        decision_path = ONTOLOGY_ROOT / gate_contract["source_edit_decision"]
        target_rdf_path = ONTOLOGY_ROOT / "00_Core_Primitives/00.03_action.rdf"
        before_hash = sha256_file(target_rdf_path)

        report = build_source_edit_gate_report(preflight_report_path, decision_path)
        after_hash = sha256_file(target_rdf_path)

        self.assertEqual(before_hash, after_hash)
        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["source_edit_gate_state"], "ready_for_manual_source_edit")
        self.assertTrue(report["manual_source_edit_required"])
        self.assertEqual(report["approved_diff_count"], 1)
        self.assertFalse(report["canonical_source_write_performed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        self.assertEqual(report["approved_diffs"][0]["source_sha256"], before_hash)
        self.assertNotIn("staged audio claim patch", target_rdf_path.read_text())

        expected = json.loads((ONTOLOGY_ROOT / gate_contract["example"]).read_text())
        self.assertEqual(report, expected)
        self.assertEqual(Path(gate_contract["example"]).suffix, ".json")

    def test_audio_claim_rdf_source_edit_gate_requires_approved_review(self):
        manifest = load_manifest()
        gate_contract = manifest["audio_claim_rdf_source_edit_gate"]
        preflight_contract = manifest["audio_claim_rdf_source_edit_preflight"]
        source_decision = ONTOLOGY_ROOT / gate_contract["source_edit_decision"]
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            decision_path = temp_root / "source_edit_decision.json"
            decision = json.loads(source_decision.read_text())
            decision["review_state"] = "rejected_by_source_editor"
            decision_path.write_text(json.dumps(decision, indent=2, sort_keys=True) + "\n")

            report = build_source_edit_gate_report(
                ONTOLOGY_ROOT / preflight_contract["example"],
                decision_path,
            )

        self.assertFalse(report["passed"])
        self.assertEqual(report["source_edit_gate_state"], "rejected")
        self.assertEqual(report["approved_diff_count"], 0)
        self.assertEqual(report["approved_diffs"], [])
        self.assertIn(
            "source edit decision must approve manual source edit",
            "\n".join(report["errors"]),
        )

    def test_audio_claim_rdf_source_edit_gate_rejects_diff_hash_mismatch(self):
        manifest = load_manifest()
        gate_contract = manifest["audio_claim_rdf_source_edit_gate"]
        preflight_contract = manifest["audio_claim_rdf_source_edit_preflight"]
        source_decision = ONTOLOGY_ROOT / gate_contract["source_edit_decision"]
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            decision_path = temp_root / "source_edit_decision.json"
            decision = json.loads(source_decision.read_text())
            decision["approved_diff_files"][0]["diff_sha256"] = "sha256:" + "0" * 64
            decision_path.write_text(json.dumps(decision, indent=2, sort_keys=True) + "\n")

            report = build_source_edit_gate_report(
                ONTOLOGY_ROOT / preflight_contract["example"],
                decision_path,
            )

        self.assertFalse(report["passed"])
        self.assertEqual(report["source_edit_gate_state"], "rejected")
        self.assertEqual(report["approved_diff_count"], 0)
        self.assertIn("decision diff hash mismatch", "\n".join(report["errors"]))

    def test_audio_claim_rdf_source_apply_fixture_is_current_without_source_overwrite(self):
        manifest = load_manifest()
        apply_contract = manifest["audio_claim_rdf_source_apply"]
        gate_contract = manifest["audio_claim_rdf_source_edit_gate"]
        gate_report_path = ONTOLOGY_ROOT / gate_contract["example"]
        target_rdf_path = ONTOLOGY_ROOT / "00_Core_Primitives/00.03_action.rdf"
        before_hash = sha256_file(target_rdf_path)

        report = build_source_apply_report(gate_report_path, write_source=False)
        after_hash = sha256_file(target_rdf_path)

        self.assertEqual(before_hash, after_hash)
        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["source_apply_state"], "ready_for_source_apply")
        self.assertEqual(report["source_write_mode"], "dry_run")
        self.assertFalse(report["canonical_source_write_performed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        self.assertEqual(report["applied_file_count"], 1)
        self.assertFalse(report["applied_files"][0]["source_write_performed"])
        self.assertEqual(report["applied_files"][0]["previous_source_sha256"], before_hash)
        self.assertNotIn("staged audio claim patch", target_rdf_path.read_text())

        expected = json.loads((ONTOLOGY_ROOT / apply_contract["example"]).read_text())
        self.assertEqual(report, expected)
        self.assertEqual(Path(apply_contract["example"]).suffix, ".json")

    def test_audio_claim_rdf_source_apply_write_mode_updates_temp_source_only(self):
        manifest = load_manifest()
        gate_contract = manifest["audio_claim_rdf_source_edit_gate"]
        target_relative_path = "00_Core_Primitives/00.03_action.rdf"
        original_target_path = ONTOLOGY_ROOT / target_relative_path
        original_hash = sha256_file(original_target_path)

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir) / "ontology"
            shutil.copytree(ONTOLOGY_ROOT, temp_root)
            gate_report_path = temp_root / gate_contract["example"]

            report = build_source_apply_report(
                gate_report_path,
                write_source=True,
                target_root=temp_root,
            )

            target_path = temp_root / target_relative_path
            staged_path = temp_root / report["applied_files"][0]["staged_rdf_file"]
            self.assertEqual(sha256_file(target_path), sha256_file(staged_path))
            self.assertIn("staged audio claim patch", target_path.read_text())

        self.assertEqual(sha256_file(original_target_path), original_hash)
        self.assertNotIn("staged audio claim patch", original_target_path.read_text())
        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["source_apply_state"], "applied")
        self.assertEqual(report["source_write_mode"], "write_source")
        self.assertTrue(report["canonical_source_write_performed"])
        self.assertTrue(report["applied_files"][0]["source_write_performed"])

    def test_audio_claim_rdf_source_apply_rejects_stale_source_hash(self):
        manifest = load_manifest()
        gate_contract = manifest["audio_claim_rdf_source_edit_gate"]
        target_relative_path = "00_Core_Primitives/00.03_action.rdf"

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir) / "ontology"
            shutil.copytree(ONTOLOGY_ROOT, temp_root)
            target_path = temp_root / target_relative_path
            target_path.write_text(
                target_path.read_text().replace("</rdf:RDF>", "  <!-- stale local edit -->\n</rdf:RDF>")
            )

            report = build_source_apply_report(
                temp_root / gate_contract["example"],
                write_source=True,
                target_root=temp_root,
            )

        self.assertFalse(report["passed"])
        self.assertEqual(report["source_apply_state"], "rejected")
        self.assertEqual(report["applied_file_count"], 0)
        self.assertFalse(report["canonical_source_write_performed"])
        self.assertIn("source hash mismatch", "\n".join(report["errors"]))

    def test_audio_claim_rdf_source_apply_verification_fixture_is_current(self):
        manifest = load_manifest()
        verification_contract = manifest["audio_claim_rdf_source_apply_verification"]
        apply_contract = manifest["audio_claim_rdf_source_apply"]
        apply_report_path = ONTOLOGY_ROOT / apply_contract["example"]
        target_rdf_path = ONTOLOGY_ROOT / "00_Core_Primitives/00.03_action.rdf"
        before_hash = sha256_file(target_rdf_path)

        report = build_source_apply_verification_report(apply_report_path)
        after_hash = sha256_file(target_rdf_path)

        self.assertEqual(before_hash, after_hash)
        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["verification_state"], "dry_run_verified")
        self.assertEqual(report["source_write_mode"], "dry_run")
        self.assertFalse(report["canonical_source_write_observed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        self.assertEqual(report["verified_file_count"], 1)
        self.assertFalse(report["verified_files"][0]["source_write_observed"])
        self.assertTrue(report["verified_files"][0]["xml_parse_verified"])
        self.assertTrue(report["verified_files"][0]["registry_read_verified"])
        self.assertGreaterEqual(report["registry_class_count"], 1)
        self.assertGreaterEqual(report["registry_object_property_count"], 1)

        expected = json.loads((ONTOLOGY_ROOT / verification_contract["example"]).read_text())
        self.assertEqual(report, expected)
        self.assertEqual(Path(verification_contract["example"]).suffix, ".json")

    def test_audio_claim_rdf_source_apply_verification_accepts_temp_write_report(self):
        manifest = load_manifest()
        gate_contract = manifest["audio_claim_rdf_source_edit_gate"]
        original_target_path = ONTOLOGY_ROOT / "00_Core_Primitives/00.03_action.rdf"
        original_hash = sha256_file(original_target_path)

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir) / "ontology"
            shutil.copytree(ONTOLOGY_ROOT, temp_root)
            apply_report = build_source_apply_report(
                temp_root / gate_contract["example"],
                write_source=True,
                target_root=temp_root,
            )
            apply_report_path = temp_root / "source_apply_report.json"
            apply_report_path.write_text(json.dumps(apply_report, indent=2, sort_keys=True) + "\n")

            report = build_source_apply_verification_report(
                apply_report_path,
                target_root=temp_root,
            )

        self.assertEqual(sha256_file(original_target_path), original_hash)
        self.assertNotIn("staged audio claim patch", original_target_path.read_text())
        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["verification_state"], "applied_source_verified")
        self.assertEqual(report["source_write_mode"], "write_source")
        self.assertTrue(report["canonical_source_write_observed"])
        self.assertTrue(report["verified_files"][0]["source_write_observed"])

    def test_audio_claim_rdf_source_apply_verification_rejects_unapplied_write_report(self):
        manifest = load_manifest()
        apply_contract = manifest["audio_claim_rdf_source_apply"]

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir) / "ontology"
            shutil.copytree(ONTOLOGY_ROOT, temp_root)
            apply_report = json.loads((temp_root / apply_contract["example"]).read_text())
            apply_report["source_apply_state"] = "applied"
            apply_report["source_write_mode"] = "write_source"
            apply_report["canonical_source_write_performed"] = True
            apply_report["applied_files"][0]["source_write_performed"] = True
            apply_report_path = temp_root / "source_apply_report.json"
            apply_report_path.write_text(json.dumps(apply_report, indent=2, sort_keys=True) + "\n")

            report = build_source_apply_verification_report(
                apply_report_path,
                target_root=temp_root,
            )

        self.assertFalse(report["passed"])
        self.assertEqual(report["verification_state"], "rejected")
        self.assertEqual(report["verified_file_count"], 0)
        self.assertFalse(report["canonical_source_write_observed"])
        self.assertIn("source apply verification hash mismatch", "\n".join(report["errors"]))

    def test_audio_claim_rdf_pipeline_receipt_fixture_is_current(self):
        manifest = load_manifest()
        receipt_contract = manifest["audio_claim_rdf_pipeline_receipt"]

        report = build_pipeline_receipt()

        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["pipeline_state"], "source_contract_pipeline_ready")
        self.assertEqual(report["proposal_id"], "audio-proposal-001")
        self.assertEqual(report["report_count"], 8)
        self.assertEqual(report["source_write_mode"], "dry_run")
        self.assertFalse(report["canonical_source_write_performed"])
        self.assertFalse(report["canonical_source_write_observed"])
        self.assertFalse(report["ontology_truth_promotion_performed"])
        self.assertFalse(report["raw_transcript_text_included"])
        self.assertEqual(report["claim_count"], 1)
        self.assertEqual(report["patch_count"], 1)
        self.assertEqual(report["target_file_count"], 1)
        self.assertEqual(report["verified_file_count"], 1)
        self.assertGreaterEqual(report["registry_class_count"], 1)
        self.assertGreaterEqual(report["registry_object_property_count"], 1)
        self.assertEqual(
            [entry["contract"] for entry in report["reports"]],
            [
                "audio_claim_acceptance",
                "audio_claim_rdf_preview",
                "audio_claim_rdf_source_promotion",
                "audio_claim_rdf_staged_apply",
                "audio_claim_rdf_source_edit_preflight",
                "audio_claim_rdf_source_edit_gate",
                "audio_claim_rdf_source_apply",
                "audio_claim_rdf_source_apply_verification",
            ],
        )

        expected = json.loads((ONTOLOGY_ROOT / receipt_contract["example"]).read_text())
        self.assertEqual(report, expected)
        self.assertEqual(Path(receipt_contract["example"]).suffix, ".json")

    def test_audio_claim_rdf_pipeline_receipt_rejects_failed_gate_report(self):
        manifest = load_manifest()
        gate_contract = manifest["audio_claim_rdf_source_edit_gate"]

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir) / "ontology"
            shutil.copytree(ONTOLOGY_ROOT, temp_root)
            gate_path = temp_root / gate_contract["example"]
            gate_report = json.loads(gate_path.read_text())
            gate_report["passed"] = False
            gate_report["source_edit_gate_state"] = "rejected"
            gate_report["errors"] = ["synthetic rejection"]
            gate_path.write_text(json.dumps(gate_report, indent=2, sort_keys=True) + "\n")

            report = build_pipeline_receipt(root=temp_root)

        self.assertFalse(report["passed"])
        self.assertEqual(report["pipeline_state"], "rejected")
        self.assertEqual(report["report_count"], 8)
        self.assertIn("audio_claim_rdf_source_edit_gate must have passed=true", "\n".join(report["errors"]))
        self.assertIn(
            "audio_claim_rdf_source_edit_gate state is not ready_for_manual_source_edit",
            "\n".join(report["errors"]),
        )

    def test_audio_claim_rdf_pipeline_receipt_rejects_proposal_id_mismatch(self):
        manifest = load_manifest()
        apply_contract = manifest["audio_claim_rdf_source_apply"]

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir) / "ontology"
            shutil.copytree(ONTOLOGY_ROOT, temp_root)
            apply_path = temp_root / apply_contract["example"]
            apply_report = json.loads(apply_path.read_text())
            apply_report["proposal_id"] = "different-proposal"
            apply_path.write_text(json.dumps(apply_report, indent=2, sort_keys=True) + "\n")

            report = build_pipeline_receipt(root=temp_root)

        self.assertFalse(report["passed"])
        self.assertEqual(report["pipeline_state"], "rejected")
        self.assertIn(
            "pipeline reports must share one non-empty proposal_id",
            "\n".join(report["errors"]),
        )

    def test_healthcare_dataset_mapping_contract_references_known_terms(self):
        contract = load_mapping_contract()
        errors = validate_contract_references(contract)

        self.assertEqual(errors, [])
        self.assertEqual(contract["domain"], "episteme://30_Healthcare")
        self.assertEqual(contract["mapping_id"], "healthcare.synthetic_care_delivery.v1")

    def test_healthcare_dataset_mapping_reports_source_contract_handoff(self):
        report = build_validation_report()

        self.assertTrue(report["passed"], report["errors"])
        self.assertEqual(report["runtime_materialization_owner"], "xiuxian-wendao")
        self.assertEqual(report["handoff_kind"], "arrow_flight_raw_tables")
        self.assertEqual(
            report["raw_table_counts"],
            {
                "raw_conditions": 2,
                "raw_encounters": 2,
                "raw_patients": 2,
                "raw_providers": 2,
            },
        )
        self.assertIn(
            "30_Healthcare/rules/01_encounter_must_link_patient_provider.sql",
            report["validation_rules"],
        )

    def test_python_contract_tool_does_not_depend_on_duckdb(self):
        pyproject = tomllib.loads((EPISTEME_ROOT / "pyproject.toml").read_text())
        dependencies = pyproject["project"]["dependencies"]

        self.assertFalse(
            any(dependency.startswith("duckdb") for dependency in dependencies),
            dependencies,
        )

    def test_healthcare_dataset_mapping_emits_arrow_ipc_raw_tables(self):
        with tempfile.TemporaryDirectory() as output_dir:
            output_path = Path(output_dir)
            written_counts = emit_raw_table_arrow_ipc(output_path)
            read_counts = read_raw_table_arrow_ipc_counts(output_path)

            self.assertEqual(
                sorted(path.name for path in output_path.iterdir()),
                [
                    "raw_conditions.arrow",
                    "raw_encounters.arrow",
                    "raw_patients.arrow",
                    "raw_providers.arrow",
                ],
            )
            self.assertEqual(written_counts, read_counts)
            self.assertEqual(
                read_counts,
                {
                    "raw_conditions": 2,
                    "raw_encounters": 2,
                    "raw_patients": 2,
                    "raw_providers": 2,
                },
            )


def sha256_file(path: Path) -> str:
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


if __name__ == "__main__":
    unittest.main()
