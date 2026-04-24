#!/usr/bin/env sh
# init creates the issue dir + README, substituting the template placeholders.
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

spool_init gh 42 rate-limit "Add rate limiting" "https://example/issues/42" "feat/rate-limit"

dir=spool/gh/issue/42-rate-limit
assert_dir "$dir"
assert_file "$dir/README.md"
assert_contains "$dir/README.md" "# Add rate limiting"
assert_contains "$dir/README.md" "**Spec:** https://example/issues/42"
assert_contains "$dir/README.md" "**Status:** in-progress"
assert_contains "$dir/README.md" "**Branch:** feat/rate-limit"
assert_contains "$dir/README.md" "## Done"
assert_contains "$dir/README.md" "## Next"
assert_contains "$dir/README.md" "## Deferred"
assert_contains "$dir/README.md" "## Pitfalls"
assert_contains "$dir/README.md" "## Open questions"
