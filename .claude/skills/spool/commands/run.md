# /spool run

**Invocation:** `/spool run <ref>` — the recommended default for starting or continuing work on an issue.

`run` composes `init` and `pickup`. It picks the right branch from filesystem state, so the user doesn't have to remember whether a spool exists yet.

## Arg shapes

All of these are valid:

- `/spool run gh:42` — explicit tracker.
- `/spool run linear:ENG-17` — explicit tracker.
- `/spool run 42` — works when only one tracker dir exists under `./spool/`; otherwise ask.
- `/spool run gh 42 rate-limit` — init-style form, useful on the first run when the slug isn't guessable from the tracker.
- `/spool run #42` — treat `#N` like the tracker-less short form.

## Hard rules

Same as every other subcommand: explicit-only, serial-within-issue, no parallel work, advisory validation.

`run` inherits `pickup`'s non-negotiable: **confirm Next with the user before editing any code.**

## Decision tree

### 1. Parse the ref

Resolve `<ref>` into tracker + id (+ slug, if provided). Defaults when ambiguous match the rules in `commands/pickup.md` §1.

### 2. Look for the issue dir

```bash
active=$(find ./spool/<tracker>/issue -maxdepth 1 -type d -name "<id>-*" ! -path '*archive*' 2>/dev/null)
archived=$(find ./spool/<tracker>/issue/archive -maxdepth 1 -type d -name "<id>-*" 2>/dev/null)
```

Three cases:

| Active found | Archived found | Action |
|---|---|---|
| yes | — | **pickup branch** — delegate to `commands/pickup.md`. |
| no | yes | Tell the user the issue was already closed. Stop. Do not init. |
| no | no | **init-then-pickup branch** — see below. |

### 3a. Pickup branch

Delegate directly to `commands/pickup.md` starting from step 2 (read the spec). Everything after is identical.

Edge case — **active dir exists but `## Next` is empty or missing.** This happens when someone ran `init` but never filled Next. Treat it as "partial init":

- Read whatever sections exist.
- Ask the user for the immediate next concrete action.
- Write it into `## Next`.
- Then proceed with pickup step 6 (confirm Next) — yes, even though the user just told you, confirm once to catch any drift between what they said and what got written. Then continue through step 7.

### 3b. Init-then-pickup branch

Delegate to `commands/init.md` for scaffolding (steps 1-4: bootstrap `./spool/`, create issue dir, seed README from template, prompt for Next).

Do NOT stop after init. Immediately flow into `commands/pickup.md` starting from step 6 (the Next-confirmation step) — there's no point re-reading the README you just wrote in steps 1-5, and steps 2-5 of pickup (read spec, glance specs, glance decisions, glance guardrails) may be empty on the first run anyway. Skim them if they exist; skip silently if they don't.

One caveat — on the very first run in a project, `./spool/docs/` and `./spool/agents/*` will be empty. That's fine. Say so to the user in one line so they know there's nothing to glance at, not that you skipped the step.

### 4. Do exactly one step

Same as `pickup` step 7. Commit with the spool commit protocol (delegate to `commands/commit.md` conventions). Update the issue's `README.md` in the same commit.

### 5. Report

Summarize: what the decision tree chose (init-then-pickup vs. pickup), what shipped, what Next now says. One or two sentences.

## When NOT to use run

- When you want to scaffold a dir without starting work yet → use `/spool init`.
- When you want to explicitly resume an existing dir and be sure init won't fire → use `/spool pickup`.
- When closing an issue → use `/spool close`. `run` does not close; closing is a distinct act.
