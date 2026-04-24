#!/usr/bin/env sh
# init refuses if the id already exists in archive (regardless of slug match).
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

mkdir -p spool/gh/issue/archive/42-original-slug
echo "# Archived" > spool/gh/issue/archive/42-original-slug/README.md

# Baseline init still works for other ids — but 42 must be refused.
if spool_init gh 42 different-slug "Resurrect" "https://example/issues/42" "feat/x" 2>/dev/null; then
    echo "expected init to refuse id that exists in archive" >&2
    exit 1
fi
