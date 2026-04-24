#!/usr/bin/env sh
# Archive move uses git mv so --follow tracks the rename.
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

spool_init gh 42 rate-limit "Add rate limiting" "https://example/issues/42" "feat/rate-limit"
git add spool
git commit -q -m "init issue 42"

# Make another commit touching the issue README so git has something to follow.
echo "- [step 1] sketched the middleware. Commit: deadbee. Tests: n/a. Verified: n/a." \
    >> spool/gh/issue/42-rate-limit/README.md
git add spool/gh/issue/42-rate-limit/README.md
git commit -q -m "step 1"

spool_archive gh 42 rate-limit
git commit -q -m "archive 42"

assert_no_dir spool/gh/issue/42-rate-limit
assert_dir spool/gh/issue/archive/42-rate-limit
assert_file spool/gh/issue/archive/42-rate-limit/README.md

# git log --follow should see pre-rename commits.
count=$(git log --follow --oneline -- spool/gh/issue/archive/42-rate-limit/README.md | wc -l)
if [ "$count" -lt 3 ]; then
    echo "expected >=3 commits via --follow, got $count" >&2
    git log --follow --oneline -- spool/gh/issue/archive/42-rate-limit/README.md >&2
    exit 1
fi
