#!/usr/bin/env sh
# /spool run chooses the right branch (pickup / archived / init) from fs state.
set -eu
TEST_SCRIPT=$0
. "$(dirname "$0")/lib.sh"

setup_repo
trap cleanup_repo EXIT

# Case 1: nothing exists → init.
decision=$(spool_run_decide gh 42)
[ "$decision" = "init" ] || { echo "expected init, got $decision"; exit 1; }

# Case 2: active dir exists → pickup.
spool_init gh 42 rate-limit "Add rate limiting" "https://example/issues/42" "feat/rate-limit"
decision=$(spool_run_decide gh 42)
[ "$decision" = "pickup" ] || { echo "expected pickup, got $decision"; exit 1; }

# Case 3: archived dir exists (no active) → archived.
git add spool
git commit -q -m "init 42"
spool_archive gh 42 rate-limit
git commit -q -m "archive 42"
decision=$(spool_run_decide gh 42)
[ "$decision" = "archived" ] || { echo "expected archived, got $decision"; exit 1; }

# Case 4: fresh id on a spooled repo → init (decision is per-id, not global).
decision=$(spool_run_decide gh 99)
[ "$decision" = "init" ] || { echo "expected init for new id, got $decision"; exit 1; }

# Note: "active AND archived both exist" is not a state /spool run or /spool init
# can produce — init refuses when the id is in archive. Not tested because it
# would assert on behavior the skill explicitly prevents.
