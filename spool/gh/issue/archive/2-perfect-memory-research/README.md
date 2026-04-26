# Research: 'perfect memory' & long-running workflow approaches in other dev-agent tools

**Spec:** https://github.com/ahoward/spool/issues/2
**Status:** in-progress
**Branch:** main

## Done
- [step 1] Surveyed ~17 tools across coding-agent CLIs, Claude-side surface, and research patterns; wrote `analysis.md` with three buckets (Adopt now / Reject / Reconsider only if egregiously good). Commit: e33588c. Tests: n/a (doc-only). Verified: read-back of analysis.md against issue acceptance criteria.

## Next
User reviews `analysis.md` and decides which "Adopt now" items (if any) to land as follow-up issues. After review, this issue closes via `/spool close 2` — no docs/ promotion expected since this is research, not a subsystem.

## Deferred

## Pitfalls
- **Self-confirmation in self-test mode.** Pickup step 6 (confirm Next with the user before coding) can't pause for input when the agent is testing itself. I proceeded under the user's prior consent ("yes" to the plan), but in normal use this would be a dialogue turn. Worth flagging in the skill body that self-test scenarios should call this out explicitly.
- **`Done` sha is `PENDING`.** The commit-protocol playbook backfills the sha via amend. That step happens after the commit lands.

## Open questions
- Of the six "Adopt now" recommendations, which (if any) does the user want as follow-up issues vs. drop?
- Is `playbooks/` worth adding to the spool convention as a peer of `docs/` and `agents/`, or out of scope?
