# Add headless / yolo mode to spool skill

**Spec:** https://github.com/ahoward/spool/issues/3
**Status:** done
**Branch:** feat/headless

## Done
- [step 1] Landed `--yolo` across SKILL.md (cross-cutting "Headless mode" rule), commands/{run,init,pickup,close,commit}.md (per-command Headless mode sections describing what each skips and what defaults each derives), issue-readme template (commented-out hint about `## Headless decisions` section), and a new fixture test asserting `--yolo` does not alter run's fs-driven decision tree. 9 tests pass. Commit: 94ae684. Tests: green. Verified: full suite + read-back of each playbook for self-consistency.
- [step 2] Loosened `close --yolo` per user decision — git is version control, every close step is a reversible commit, so `close --yolo` no longer refuses on ambiguous promotion or `Status != done`; both become logged auto-decisions. SKILL.md's refusal list updated to match. 9 tests still pass. Commit: dca88cd. Tests: green. Verified: re-read close.md and SKILL.md for self-consistency.

## Next
User reviews PR #4 (now contains both commits). Merge or request changes.

## Deferred
- Actually testing `--yolo close` end-to-end. The flag is documented but not exercised by a test because close has no extracted shell helper to drive. Will validate manually on the next real close.
- Auto-detection of "decided:" markers in commit history for `close --yolo` step 3. Documented as the rule, but the parser logic will only get exercised when a real headless close runs.

## Pitfalls
- **`commit.md` already had a `--no-verify`-style amend caveat** ("if the user has configured a policy against amends, skip"). The new headless block should NOT bypass that policy — added a note that headless preserves discipline including any user amend policy. Worth re-reading the close playbook with the same lens at next close.

## Open questions
- ~~Should `close --yolo` ever auto-promote to `docs/<subsystem>.md` if the issue body explicitly says "Promote to: docs/foo.md"?~~ Resolved by step 2 — `close --yolo` now auto-promotes when a target is named anywhere (body, commit footer, or `## Open questions`); when not named, it skips promotion and logs the skip rather than refusing.

## Headless decisions
### 2026-04-24
- Auto-confirmed Next from the issue spec ("Land the headless flag across …") because the parent invocation was implicitly headless ("1, 2, and 3" was a green-light to proceed without per-step prompts).
- Auto-confirmed step 2's Next ("loosen close --yolo per user decision") for the same reason — user decision was unambiguous in the conversation.
