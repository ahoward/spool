# Closing an issue

When work on a `spool/<tracker>/issue/<id>-<slug>/` is done, the close ritual carries the lessons forward and freezes the working dir.

The point: nothing useful gets stuck inside the issue. Every reusable thing — current truth, why-it-was-decided, agent failure modes, recurring patterns — moves to its long-lived home. The issue dir then archives intact, addressable forever via git history.

## Steps

1. **Promote to specs.** Update `spool/docs/<subsystem>.md` to describe what *is* now. Skip if the issue didn't shift any subsystem's truth.
2. **Log decisions.** Append dated entries (newest at top) to `spool/agents/decisions.md` for choices future-work might revisit. Include considered alternatives when relevant.
3. **Update guardrails.** Append to `spool/agents/guardrails.md` for any failure mode worth not repeating. One short line each.
4. **Promote playbooks.** If a pattern from this work is reusable, write or update `spool/playbooks/<name>.md`. Short — paragraph + numbered list.
5. **Archive.** `git mv spool/<tracker>/issue/<id>-<slug> spool/<tracker>/issue/archive/<id>-<slug>`.
6. **Commit.** `chore(spool): close #<id>, promote to docs/<subsystem>.md, archive`. One paragraph body summarizing what promoted where.

## When to skip a step

- **No spec promotion** if the issue didn't change current truth (e.g., research-only issues).
- **No decision logged** if no choice was non-obvious or needed explaining later.
- **No guardrails** if no agent failed in an interesting way.
- **No playbook** if the work was too one-off to recur.

Skipping is fine. Skipping all five is suspicious — at minimum, the archive happens.

## See also

- `.claude/skills/spool/commands/close.md` — the skill's interactive walkthrough of these steps.
- Project README §"The promotion ritual (issue close)" — the canonical description.
