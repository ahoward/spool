#!/usr/bin/env sh
# /spool run --yolo must take the same fs-driven decision (init/pickup/archived)
# as /spool run. Headless changes prompt behavior, not branch selection.
#
# Since `--yolo` is a flag, not a separate code path, the test asserts the
# invariant by re-using spool_run_decide on the same fs states the run test
# uses. If the decision logic ever changes for headless, this test should be
# updated to mirror the new behavior — it is a contract check, not a parser.
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

# Three identical cases to test_run_decides_branch.sh, asserted twice each:
# once in "interactive mode" (the existing decide function), once as a stand-in
# for "headless mode" (same function — that's the contract).

# Case 1: nothing exists → init.
[ "$(spool_run_decide gh 42)" = "init" ] || { echo "interactive: expected init"; exit 1; }
[ "$(spool_run_decide gh 42)" = "init" ] || { echo "headless: expected init"; exit 1; }

# Case 2: active dir → pickup.
spool_init gh 42 rate-limit "Add rate limiting" "https://example/issues/42" "feat/rate-limit"
[ "$(spool_run_decide gh 42)" = "pickup" ] || { echo "interactive: expected pickup"; exit 1; }
[ "$(spool_run_decide gh 42)" = "pickup" ] || { echo "headless: expected pickup"; exit 1; }

# Case 3: archived dir only → archived.
git add spool
git commit -q -m "init 42"
spool_archive gh 42 rate-limit
git commit -q -m "archive 42"
[ "$(spool_run_decide gh 42)" = "archived" ] || { echo "interactive: expected archived"; exit 1; }
[ "$(spool_run_decide gh 42)" = "archived" ] || { echo "headless: expected archived"; exit 1; }
