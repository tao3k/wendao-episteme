set shell := ["bash", "-uc"]

self_root := justfile_directory()

default:
    @just --justfile '{{ self_root }}/justfile' --list

test-python-align:
    #!/usr/bin/env bash
    set -euo pipefail

    SELF_ROOT='{{ self_root }}'

    echo "== python episteme align tests ==" >&2
    (
      cd "$SELF_ROOT"
      python -m unittest discover -s tests -p 'test_*.py'
    )

build-wendao:
    #!/usr/bin/env bash
    set -euo pipefail

    SELF_ROOT='{{ self_root }}'
    SUPERPROJECT_ROOT="$(git -C "$SELF_ROOT" rev-parse --show-superproject-working-tree)"

    if [[ -z "$SUPERPROJECT_ROOT" ]]; then
      echo "error: wendao-episteme tests must execute from a checked-out superproject" >&2
      exit 1
    fi

    echo "== build wendao ==" >&2
    (
      cd "$SUPERPROJECT_ROOT"
      direnv exec . cargo build -p xiuxian-wendao --bin wendao
    )

test: build-wendao test-python-align
    #!/usr/bin/env bash
    set -euo pipefail

    SELF_ROOT='{{ self_root }}'
    SUPERPROJECT_ROOT="$(git -C "$SELF_ROOT" rev-parse --show-superproject-working-tree)"
    WENDAO_BIN="${WENDAO_BIN:-$SUPERPROJECT_ROOT/target/debug/wendao}"

    if [[ -z "$SUPERPROJECT_ROOT" ]]; then
      echo "error: wendao-episteme tests must execute from a checked-out superproject" >&2
      exit 1
    fi

    run_wendao() {
      (
        cd "$SUPERPROJECT_ROOT"
        "$WENDAO_BIN" "$@"
      )
    }

    run_expected_lint_failure() {
      local scenario="$1"
      echo "== lint expected-failure $(basename "$scenario") ==" >&2
      if run_wendao --root "$scenario" lint markdown docs >/dev/null 2>&1; then
        echo "error: expected lint failure for $scenario" >&2
        exit 1
      fi
    }

    for framework in \
      johnny-decimal \
      diataxis \
      evergreen-notes \
      adr \
      moc \
      folgezettel \
      ibis \
      structural-proprioception \
      search-reasoning \
      semantic-consistency \
      epistemic-sensemaking \
      temporal-scaffolding; do
      echo "== audit template $framework ==" >&2
      run_wendao audit --template "$framework" >/dev/null
    done

    for scenario in "$SELF_ROOT"/tests/fixtures/frameworks/*; do
      [[ -d "$scenario/docs" ]] || continue
      echo "== lint $(basename "$scenario") ==" >&2
      run_wendao --root "$scenario" lint markdown docs >/dev/null
    done

    run_expected_lint_failure "$SELF_ROOT/tests/fixtures/commands/lint_invalid_frontmatter"
    run_expected_lint_failure "$SELF_ROOT/tests/fixtures/commands/lint_invalid_skill_frontmatter_schema"

    echo "== lint valid_skill_frontmatter_schema ==" >&2
    run_wendao \
      --root "$SELF_ROOT/tests/fixtures/commands/lint_valid_skill_frontmatter_schema" \
      lint markdown docs >/dev/null

    echo "== audit load repo root ==" >&2
    run_wendao \
      --root "$SELF_ROOT/tests/fixtures/frameworks/johnny_decimal" \
      audit --load "$SELF_ROOT" docs >/dev/null

    echo "== audit load manifest file ==" >&2
    run_wendao \
      --root "$SELF_ROOT/tests/fixtures/frameworks/diataxis" \
      audit --load "$SELF_ROOT/episteme.toml" docs >/dev/null

    echo "wendao-episteme command checks passed" >&2
