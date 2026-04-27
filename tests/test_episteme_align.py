import unittest

from tools.wendao_episteme_align.__main__ import (
    SourceEntry,
    chunk_text,
    entrypoint_urls,
    is_fetchable_source_type,
    is_local_source_type,
    resolve_local_source_path,
    sanitize_error_body,
)


class EpistemeAlignTests(unittest.TestCase):
    def test_entrypoint_urls_resolve_from_source_origin(self):
        source = SourceEntry(
            id="demo",
            name="Demo",
            url="https://example.test/root/page",
            source_type="website",
            enabled=True,
            entrypoints=("/alpha", "beta", "https://other.test/gamma"),
            authority="practice_reference",
            notes="",
            path="",
        )

        self.assertEqual(
            entrypoint_urls(source),
            [
                "https://example.test/alpha",
                "https://example.test/root/beta",
                "https://other.test/gamma",
            ],
        )

    def test_chunk_text_keeps_short_markdown_together(self):
        chunks = chunk_text("# Title\n\nBody paragraph.\n\n## Next\n\nMore text.", chunk_chars=200)

        self.assertEqual(chunks, ["# Title\n\nBody paragraph.\n\n## Next\n\nMore text."])

    def test_chunk_text_splits_large_paragraph(self):
        chunks = chunk_text("a" * 25, chunk_chars=10)

        self.assertEqual(chunks, ["a" * 10, "a" * 10, "a" * 5])

    def test_sanitize_error_body_redacts_provider_keys(self):
        body = "bad fc-demo-secret"

        self.assertEqual(
            sanitize_error_body(body),
            "bad fc-[redacted]",
        )

    def test_fetchable_source_types_include_papers_and_websites(self):
        self.assertTrue(is_fetchable_source_type("paper"))
        self.assertTrue(is_fetchable_source_type("website"))
        self.assertFalse(is_fetchable_source_type("github_repo"))

    def test_local_source_types_include_local_docs_and_files(self):
        self.assertTrue(is_local_source_type("local_doc"))
        self.assertTrue(is_local_source_type("local_file"))
        self.assertFalse(is_local_source_type("website"))

    def test_resolve_local_source_path_accepts_episteme_relative_paths(self):
        source = SourceEntry(
            id="conflict-matrix",
            name="Conflict Matrix",
            url="policies/conflicts/manifest.toml",
            source_type="local_file",
            enabled=True,
            entrypoints=(),
            authority="governed_policy",
            notes="",
            path="policies/conflicts/manifest.toml",
        )

        self.assertTrue(resolve_local_source_path(source).exists())


if __name__ == "__main__":
    unittest.main()
