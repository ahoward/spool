---
name: spool
description: Manage spool — the in-repo convention for serial multi-session work. Use only when the user types one of `/spool run`, `/spool pickup`, `/spool init`, `/spool close`, `/spool commit`, or `/spool status`. Do NOT invoke implicitly on casual references to issue IDs.
---

# spool

Spool is a filesystem convention inside a project's repo that gives every multi-session piece of work a live working directory, a promotion path into long-lived specs, and a frozen archive at close. This skill automates the conventions the project README spells out.

**Canonical reference:** `./README.md` at the project root describes the convention. When in doubt, re-read it.

## Hard rules — read before every subcommand

1. **Explicit only.** This skill runs only when the user types a `/spool …` command. Never fire from casual mentions like "issue 42" or "#42" in conversation.
2. **Serial within an issue.** Within one spooled issue: no `git worktree`, no parallel sub-agents via Agent, no "I'll do step 3 and step 5 at once." One thread, one loose end. Different issues can spool concurrently, but inside one issue, work is strictly sequential.
3. **Confirm before coding.** On pickup, you must surface the issue's README `Next` line and ask the user to confirm it before editing any code. This is the single most important guardrail — the whole methodology fails without it.
4. **Advisory validation.** If a spool README is missing sections or malformed, point it out but do not refuse to proceed. Schema strictness is a v1 concern.
5. **Ask, don't assume.** When subcommands need information not in the args (tracker, subsystem, slug), ask the user.

## Routing

Route to the matching command playbook in `commands/`:

| User types | Playbook |
|---|---|
| `/spool run <ref>` | `commands/run.md` *(recommended default)* |
| `/spool pickup <ref>` | `commands/pickup.md` |
| `/spool init <tracker> <id> <slug>` | `commands/init.md` |
| `/spool close <id>` | `commands/close.md` |
| `/spool commit` | `commands/commit.md` |
| `/spool status` | `commands/status.md` |

`run` is the sugar — it decides init-vs-pickup from filesystem state. `init` and `pickup` remain as primitives for when the user wants to be explicit.

If the user types `/spool` with no subcommand, list the six subcommands and ask which they want.

If the user types `/spool <unknown>`, say so and list the six valid subcommands.

## Files and paths

All spool state lives under `./spool/` in the project. This skill never writes outside `./spool/` except:
- The issue branch's own code changes (during pickup's "do one step").
- Commits and their messages.

Directory shape (from the project README):

```
./spool/
  README.md
  docs/<subsystem>.md
  agents/decisions.md
  agents/guardrails.md
  <tracker>/issue/<id>-<slug>/README.md
  <tracker>/issue/archive/<id>-<slug>/README.md
```

Tracker namespace is part of the path (`gh/`, `linear/`, `jira/`, …). Ask the user which tracker when it isn't obvious.

## Templates

When creating or updating files, pull from `./.claude/skills/spool/templates/`:

- `issue-readme.md` — the Done/Next/Deferred/Pitfalls/Open questions template for issue working dirs.
- `decision-entry.md` — the shape of a single entry appended to `./spool/agents/decisions.md`.
- `guardrail-entry.md` — the shape of an entry in `./spool/agents/guardrails.md`.

## On any tool's absence

If `./spool/` does not exist yet in the repo, only `/spool init` should create it. For other subcommands, tell the user the project isn't spooled and suggest `/spool init` as the first move.

## Headless mode (`--yolo`)

Off by default. Enabled per-invocation only — never persisted, never inferred.

`/spool <subcommand> --yolo [args...]` means "skip prompts, proceed with sane defaults." It applies to: `run`, `init`, `pickup`, `close`, `commit`. It is a no-op on `status` (already read-only).

**Headless skips prompts, not discipline.** All of these still apply under `--yolo`:

- The serial constraint (no parallel work).
- The commit protocol (subject/body/footer + same-commit README update).
- One-step-per-commit on pickup/run.
- The advisory-validation rules — and headless ≠ reckless: malformed READMEs still abort.

**Audit trail.** Every prompt that would have asked the user gets logged to a `## Headless decisions` section in the issue README, grouped under a `### <YYYY-MM-DD>` subheading per session, one bullet per skipped prompt. The section is created on first headless action; do not pre-seed it in the template.

**When headless refuses.** Headless leans into git as the safety net — every spool action is a commit and is reversible. The remaining refusals are about cases where there's nothing sensible to do:

- Any subcommand refuses on a corrupt or missing issue README — there's no state to act on.
- `/spool close --yolo` refuses if the issue dir doesn't exist or is already archived — nothing to close.
- `/spool init --yolo` refuses if it can't auto-derive a title from the tracker — there's no name to give the dir.
- `/spool pickup --yolo` refuses if `## Next` is empty — the gate exists for a reason and there's no sane default.
- `/spool commit --yolo` refuses on an empty staged diff — nothing to commit.

When headless refuses, say so explicitly and tell the user to drop `--yolo`.

**Defaults derived under `--yolo`.** Each command playbook documents its own defaults in its own `## Headless mode` section. The general rule: derive from the filesystem and tracker first; fall back to convention (`<type>/<slug>` for branch, slug-from-title) only when nothing better exists.
