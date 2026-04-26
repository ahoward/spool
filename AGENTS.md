# Agents

This repo uses **spool** — a filesystem convention for serial multi-session work. Read these files before doing anything:

- [`spool/README.md`](spool/README.md) — project-local conventions for spool.
- [`spool/<tracker>/issue/<id>-<slug>/README.md`](spool/) — state of any active in-progress issue. Status, Done, Next, Deferred, Pitfalls, Open questions.
- [`spool/agents/decisions.md`](spool/agents/decisions.md) — dated log of why key choices were made.
- [`spool/agents/guardrails.md`](spool/agents/guardrails.md) — short list of agent failure modes to stop re-proposing.
- [`spool/docs/<subsystem>.md`](spool/docs/) — current-truth specs for each subsystem.

The spool convention itself is described in this repo's [`README.md`](README.md). The Claude Code skill that automates it lives at [`.claude/skills/spool/`](.claude/skills/spool/).

## Working on an issue

If a `spool/<tracker>/issue/<id>-<slug>/` directory exists for what you're being asked to do, **read its `README.md` before touching code.** That file is the source of truth for state, not the issue tracker.

If you have access to the spool skill, use `/spool run <ref>` (recommended) or `/spool pickup <ref>` instead of starting work directly.
