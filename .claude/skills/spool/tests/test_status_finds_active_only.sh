#!/usr/bin/env sh
# The status find command returns active issue dirs only, not archived ones.
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

spool_init gh 42 rate-limit "Add rate limiting" "https://example/issues/42" "feat/rate-limit"
spool_init gh 51 docs       "Docs rewrite"      "https://example/issues/51" "feat/docs"
spool_init linear ENG-17 eng-17 "Payments bug" "https://example/ENG-17" "fix/eng-17"
git add spool
git commit -q -m "init three issues"

# Archive one of them.
spool_archive gh 51 docs
git commit -q -m "archive 51"

# This mirrors commands/status.md step 1.
active=$(find ./spool -mindepth 3 -maxdepth 3 -type d -path '*/issue/*' ! -path '*/archive*' ! -name archive | sort)

expected="./spool/gh/issue/42-rate-limit
./spool/linear/issue/ENG-17-eng-17"

if [ "$active" != "$expected" ]; then
    echo "active mismatch" >&2
    printf 'got:\n%s\n' "$active" >&2
    printf 'want:\n%s\n' "$expected" >&2
    exit 1
fi
