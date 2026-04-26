# Add spool/playbooks/ as a peer of docs/ and agents/

**Spec:** https://github.com/ahoward/spool/issues/9
**Status:** done
**Branch:** feat/playbooks

## Done
- [step 1] Added `spool/playbooks/` as a peer of `spool/docs/` and `spool/agents/`. Updated the project README (Layout block, "five kinds of files" rename, new §5, promotion ritual now has 6 steps with playbooks at step 4, pickup protocol step 4 mentions playbooks). Updated SKILL.md, commands/pickup.md (new step 5 includes playbook grep), commands/run.md (caveat mentions playbooks too), commands/close.md (new step 4.5: promote playbooks). Seeded `spool/playbooks/closing-an-issue.md` as the first playbook — condenses the close ritual to a paragraph + numbered list, demonstrating the shape. 8 tests pass. Commit: 5a294f5. Tests: green. Verified: full suite + read-back of project README and the seed playbook.

## Next
PR review. Wait for #10 to land first since both touch the issue-README template's surrounding context (no actual conflict since #10 doesn't touch project README, SKILL.md routing, or playbooks-related lines — but worth eyeballing).

## Deferred
- A `playbooks-index.md` or grep helper. The README's "grep playbooks for keywords" works for the v0 library size; revisit when the dir grows past ~10 playbooks.

## Pitfalls

## Open questions
- Should the close playbook (`closing-an-issue.md`) duplicate or just point at the project README's promotion ritual? Currently does both — paragraph + steps inline, with a "see also" pointing at the canonical source. Slightly redundant, deliberately so: a playbook should be readable standalone.
