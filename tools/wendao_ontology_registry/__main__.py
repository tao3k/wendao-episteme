from __future__ import annotations

import argparse
import json
import sys
import tomllib
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any


RDF_NS = "{http://www.w3.org/1999/02/22-rdf-syntax-ns#}"
RDFS_NS = "{http://www.w3.org/2000/01/rdf-schema#}"
OWL_NS = "{http://www.w3.org/2002/07/owl#}"


def episteme_root() -> Path:
    return Path(__file__).resolve().parents[2]


def ontology_root() -> Path:
    return episteme_root() / "ontology"


def load_toml(path: Path) -> dict[str, Any]:
    return tomllib.loads(path.read_text())


def text_of(node: ET.Element | None) -> str:
    if node is None or node.text is None:
        return ""
    return node.text.strip()


def local_name(iri: str) -> str:
    if "#" in iri:
        return iri.rsplit("#", 1)[1]
    return iri.rstrip("/").rsplit("/", 1)[-1]


def collect_rdf_terms(manifest: dict[str, Any]) -> dict[str, list[dict[str, Any]]]:
    classes = []
    object_properties = []

    for domain in manifest["domains"]:
        for relative_path in domain.get("rdf_files", []):
            path = ontology_root() / relative_path
            root = ET.parse(path).getroot()

            for class_node in root.findall(f"{OWL_NS}Class"):
                iri = class_node.attrib.get(f"{RDF_NS}about")
                if not iri:
                    continue
                classes.append(
                    {
                        "api_candidate": local_name(iri),
                        "domain": domain["id"],
                        "iri": iri,
                        "label": text_of(class_node.find(f"{RDFS_NS}label")),
                        "source_file": relative_path,
                    }
                )

            for property_node in root.findall(f"{OWL_NS}ObjectProperty"):
                iri = property_node.attrib.get(f"{RDF_NS}about")
                if not iri:
                    continue
                domain_node = property_node.find(f"{RDFS_NS}domain")
                range_node = property_node.find(f"{RDFS_NS}range")
                object_properties.append(
                    {
                        "api_candidate": local_name(iri),
                        "domain": domain["id"],
                        "iri": iri,
                        "label": text_of(property_node.find(f"{RDFS_NS}label")),
                        "source_file": relative_path,
                        "from_iri": (
                            domain_node.attrib.get(f"{RDF_NS}resource")
                            if domain_node is not None
                            else None
                        ),
                        "to_iri": (
                            range_node.attrib.get(f"{RDF_NS}resource")
                            if range_node is not None
                            else None
                        ),
                    }
                )

    return {
        "classes": sorted(classes, key=lambda item: (item["domain"], item["iri"])),
        "object_properties": sorted(
            object_properties,
            key=lambda item: (item["domain"], item["iri"]),
        ),
    }


def normalize_entries(entries: list[dict[str, Any]], sort_key: str = "api_name") -> list[dict[str, Any]]:
    return sorted(
        [dict(sorted(entry.items())) for entry in entries],
        key=lambda item: item[sort_key],
    )


def build_rule_entries(manifest: dict[str, Any]) -> list[dict[str, str]]:
    rules = []
    for domain in manifest["domains"]:
        for rule in domain.get("rules", []):
            rules.append(
                {
                    "domain": domain["id"],
                    "kind": "read_only_sql_validation",
                    "path": rule,
                }
            )
    return sorted(rules, key=lambda item: (item["domain"], item["path"]))


def build_policy_entries(manifest: dict[str, Any]) -> list[dict[str, str]]:
    policies = []
    for domain in manifest["domains"]:
        for policy in domain.get("policies", []):
            policies.append(
                {
                    "domain": domain["id"],
                    "kind": "policy_markdown",
                    "path": policy,
                }
            )
    return sorted(policies, key=lambda item: (item["domain"], item["path"]))


def build_registry() -> dict[str, Any]:
    manifest = load_toml(ontology_root() / "manifest.toml")
    api_surface = load_toml(ontology_root() / manifest["api_surface"]["file"])
    rdf_terms = collect_rdf_terms(manifest)

    return {
        "schema_version": 1,
        "ontology": api_surface["ontology"],
        "compatibility": api_surface["compatibility"],
        "source_contract": {
            "manifest": "manifest.toml",
            "api_surface": manifest["api_surface"]["file"],
            "artifact_mode": api_surface["boundaries"]["artifact_mode"],
            "mutation_allowed": api_surface["boundaries"]["mutation_allowed"],
            "runtime_compilation_owner": api_surface["boundaries"]["runtime_compilation_owner"],
            "sdk_generation_owner": api_surface["boundaries"]["sdk_generation_owner"],
        },
        "reference_nouns": sorted(manifest["api_surface"]["reference_nouns"]),
        "domains": normalize_entries(manifest["domains"], sort_key="id"),
        "rdf_terms": rdf_terms,
        "api": {
            "object_types": normalize_entries(api_surface["object_types"]),
            "link_types": normalize_entries(api_surface["link_types"]),
            "action_types": normalize_entries(api_surface["action_types"]),
            "query_types": normalize_entries(api_surface["query_types"]),
            "interface_types": normalize_entries(api_surface["interface_types"]),
        },
        "rules": build_rule_entries(manifest),
        "policies": build_policy_entries(manifest),
    }


def registry_text(registry: dict[str, Any]) -> str:
    return json.dumps(registry, indent=2, sort_keys=True) + "\n"


def write_registry(path: Path) -> None:
    path.write_text(registry_text(build_registry()))


def check_registry(path: Path) -> bool:
    expected = registry_text(build_registry())
    return path.read_text() == expected


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Compile the Wendao ontology registry snapshot.")
    parser.add_argument(
        "--output",
        default=str(ontology_root() / "registry.json"),
        help="Registry snapshot output path.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Check that the output path already matches generated registry content.",
    )
    args = parser.parse_args(argv)

    output = Path(args.output)
    if args.check:
        if check_registry(output):
            return 0
        print(f"registry snapshot is stale: {output}", file=sys.stderr)
        return 1

    write_registry(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
