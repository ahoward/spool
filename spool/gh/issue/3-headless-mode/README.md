# Add headless / yolo mode to spool skill

**Spec:** https://github.com/ahoward/spool/issues/3
**Status:** done
**Branch:** feat/headless

## Done
- [step 1] Landed `--yolo` across SKILL.md (cross-cutting "Headless mode" rule), commands/{run,init,pickup,close,commit}.md (per-command Headless mode sections describing what each skips and what defaults each derives), issue-readme template (commented-out hint about `## Headless decisions` section), and a new fixture test asserting `--yolo` does not alter run's fs-driven decision tree. 9 tests pass. Commit: 94ae684. Tests: green. Verified: full suite + read-back of each playbook for self-consistency.

## Next
User reviews PR. Issue closes after merge via `/spool close 3` — promotion target is `spool/docs/headless.md` (a small subsystem doc) if the user agrees, otherwise close without promotion since this is more "skill behavior" than "subsystem."

## Deferred
- Actually testing `--yolo close` end-to-end. The flag is documented but not exercised by a test because close has no extracted shell helper to drive. Will validate manually on the next real close.
- Auto-detection of "decided:" markers in commit history for `close --yolo` step 3. Documented as the rule, but the parser logic will only get exercised when a real headless close runs.

## Pitfalls
- **`commit.md` already had a `--no-verify`-style amend caveat** ("if the user has configured a policy against amends, skip"). The new headless block should NOT bypass that policy — added a note that headless preserves discipline including any user amend policy. Worth re-reading the close playbook with the same lens at next close.

## Open questions
- Should `close --yolo` ever auto-promote to `docs/<subsystem>.md` if the issue body explicitly says "Promote to: docs/foo.md"? Current playbook refuses on ambiguity; an explicit declaration in the issue body is *not* ambiguous, but I left the rule conservative. Decision deferred to user.

## Headless decisions
### 2026-04-24
- Auto-confirmed Next from the issue spec ("Land the headless flag across …") because the parent invocation was implicitly headless ("1, 2, and 3" was a green-light to proceed without per-step prompts).
