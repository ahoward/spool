#!/usr/bin/env sh
# After init, the resulting README has no unresolved {{PLACEHOLDER}} tokens.
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

spool_init gh 42 rate-limit "Add rate limiting" "https://example/issues/42" "feat/rate-limit"

if grep -n '{{[A-Z_]*}}' spool/gh/issue/42-rate-limit/README.md; then
    echo "unresolved placeholders above" >&2
    exit 1
fi
