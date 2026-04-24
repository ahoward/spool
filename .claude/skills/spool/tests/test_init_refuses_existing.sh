#!/usr/bin/env sh
# init refuses to clobber an existing issue dir.
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

spool_init gh 42 rate-limit "Add rate limiting" "https://example/issues/42" "feat/rate-limit"

# Write a marker file so we can detect clobbering.
echo "do not clobber" > spool/gh/issue/42-rate-limit/marker.txt

# Second init with same id/slug must fail.
if spool_init gh 42 rate-limit "Another title" "https://example/issues/42" "feat/other" 2>/dev/null; then
    echo "expected second init to fail" >&2
    exit 1
fi

# Marker survived.
assert_contains spool/gh/issue/42-rate-limit/marker.txt "do not clobber"
