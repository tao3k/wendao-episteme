#!/usr/bin/env bash
set -euo pipefail

SELF_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUPERPROJECT_ROOT="$(git -C "$SELF_ROOT" rev-parse --show-superproject-working-tree)"

if [[ -z "$SUPERPROJECT_ROOT" ]]; then
  echo "error: tests/run.sh must execute from a checked-out superproject" >&2
  exit 1
fi

run_wendao() {
  (
    cd "$SUPERPROJECT_ROOT"
    direnv exec . cargo run -p xiuxian-wendao --bin wendao -- "$@"
  )
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "assertion failed: $label" >&2
    echo "expected to find: $needle" >&2
    exit 1
  fi
}

lint_valid_framework_fixtures() {
  local scenario
  for scenario in "$SELF_ROOT"/tests/fixtures/frameworks/*; do
    [[ -d "$scenario/docs" ]] || continue
    echo "== lint $(basename "$scenario") ==" >&2
    local output
    output="$(run_wendao --root "$scenario" lint markdown docs 2>&1)"
    assert_contains "$output" "Markdown lint passed:" "lint should pass for $(basename "$scenario")"
  done
}

lint_invalid_frontmatter_fixture() {
  local scenario="$SELF_ROOT/tests/fixtures/commands/lint_invalid_frontmatter"
  echo "== lint invalid_frontmatter ==" >&2
  set +e
  local output
  output="$(run_wendao --root "$scenario" lint markdown docs 2>&1)"
  local status=$?
  set -e
  if [[ $status -eq 0 ]]; then
    echo "assertion failed: invalid frontmatter fixture should fail lint" >&2
    exit 1
  fi
  assert_contains "$output" "invalid_frontmatter_yaml" "lint should report invalid frontmatter yaml"
}

audit_load_repository_root() {
  local scenario="$SELF_ROOT/tests/fixtures/frameworks/johnny_decimal"
  echo "== audit load repo root ==" >&2
  local output
  output="$(run_wendao --root "$scenario" audit --load "$SELF_ROOT" docs 2>&1)"
  assert_contains "$output" '<episteme status="loaded" name="wendao-episteme"' "audit should load episteme repository root"
  assert_contains "$output" 'policy_queries="13"' "audit should report current episteme policy count"
  assert_contains "$output" 'docs/random_anchor' "audit should inspect fixture docs"
}

audit_load_manifest_file() {
  local scenario="$SELF_ROOT/tests/fixtures/frameworks/diataxis"
  echo "== audit load manifest file ==" >&2
  local output
  output="$(run_wendao --root "$scenario" audit --load "$SELF_ROOT/episteme.toml" docs 2>&1)"
  assert_contains "$output" '<episteme status="loaded" name="wendao-episteme"' "audit should load direct episteme.toml path"
  assert_contains "$output" 'manifest_path="'"$SELF_ROOT"'/episteme.toml"' "audit should report direct manifest path"
}

main() {
  lint_valid_framework_fixtures
  lint_invalid_frontmatter_fixture
  audit_load_repository_root
  audit_load_manifest_file
  echo "wendao-episteme smoke tests passed" >&2
}

main "$@"
