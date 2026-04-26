# spool close: promoted docs don't reflect actual shipped state

**Spec:** https://github.com/ahoward/spool/issues/12
**Status:** done
**Branch:** fix/close-ritual-doc-quality

## Done
- [step 1] Reshaped `commands/close.md` step 2 (Promote to evolving specs) into three sub-steps in mandatory order: 2a scan existing `spool/docs/` for staleness BEFORE asking the user, 2b ask the user (now informed by the scan), 2c draft from code not from conversation memory. Also threaded the "draft from code" + "scan existing" principles into the project README's promotion ritual step 1, since the README is the canonical description. 8 tests still pass. Commit: 31cac75. Tests: green. Verified: full suite + read-back of close.md and project README.

## Next
PR review.

## Deferred
- A test for the new step. There is no shell-driveable assertion ("did the agent read the source files?") — this is a Layer-3 behavioral concern, not a Layer-1 mechanical one. The fix is prose enforcement in the playbook.

## Pitfalls

## Open questions
- Should `--yolo close` get a hard refusal when `spool/docs/` contains files but the issue's diff doesn't obviously map to any of them? Current `--yolo close` skips promotion silently when no target is named. The new step 2a in interactive mode would catch staleness; under `--yolo` it would still skip. Maybe acceptable since `--yolo close` already trades precision for speed, but worth a follow-up if the failure mode persists.
