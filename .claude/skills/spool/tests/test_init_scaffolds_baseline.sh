#!/usr/bin/env sh
# init creates the baseline spool/ tree on a fresh repo.
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

spool_init gh 42 rate-limit "Add rate limiting" "https://example/issues/42" "feat/rate-limit"

assert_dir spool
assert_dir spool/docs
assert_dir spool/agents
assert_dir spool/gh/issue/archive
assert_file spool/README.md
assert_file spool/agents/decisions.md
assert_file spool/agents/guardrails.md
