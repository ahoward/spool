# /spool close

**Invocation:** `/spool close <id>` (with optional `<tracker>:` prefix on `<id>`).

Walk the five-step promotion ritual. Interactive — ask before each step.

## Steps

### 1. Resolve and sanity-check

Find the issue dir: `find ./spool/<tracker>/issue -maxdepth 1 -type d -name "<id>-*"`. If not found or already under `archive/`, tell the user and stop.

Read the issue README. If `Status:` is not `done`, ask the user to confirm they really want to close anyway.

### 2. Promote to evolving specs

Ask: **which `./spool/docs/<subsystem>.md` file(s) should reflect what shipped?** The user may name an existing file or a new subsystem.

For each named file:

- If it exists, read it. Propose merged content that describes what *is* now (not what's planned).
- If it's new, draft it from scratch.

Show the proposed spec content to the user for approval. Apply edits once approved.

Principles (from the project README):

- Describe what *is*, not what's planned. Aspirational content stays out.
- Subsystem granularity — one file per "thing you'd want to read to understand how X works."

### 3. Log decisions

Ask the user: **any key decisions from this issue worth logging?** For each, append an entry to `./spool/agents/decisions.md` using the template:

```
## <YYYY-MM-DD> — <short headline> (#<id>)

<one-paragraph why: reasoning, alternatives, context>
```

Insert at the top (newest-first). Use today's date (the actual date, not a placeholder — resolve via `date +%Y-%m-%d`).

### 4. Update guardrails if needed

Ask: **did any agent fail in a way the team should know about?** For each new guardrail, append a line to `./spool/agents/guardrails.md` using the template. Keep it short.

If the issue's `## Pitfalls` section uses the per-attempt structure (`### Attempt N` with `Tried:`/`Failed because:`/`Next attempt should:`), prefer the **"Next attempt should..."** line as the guardrail text — that's the actionable part. Fall back to a flat one-line summary for incidental Pitfalls without the structure.

### 5. Archive the issue dir

```bash
mkdir -p spool/<tracker>/issue/archive
git mv spool/<tracker>/issue/<id>-<slug> spool/<tracker>/issue/archive/<id>-<slug>
```

Prefer `git mv` over plain `mv` so git tracks the rename explicitly.

### 6. Commit

Stage everything in `./spool/` and commit:

```
chore(spool): close #<id>, promote to docs/<subsystem>.md, archive

<one short paragraph on what promoted where>

Spool: spool/<tracker>/issue/archive/<id>-<slug>/README.md
Refs: #<id>
```

Ask the user for approval before running `git commit`.

### 7. Report

Summarize what promoted where, what decisions logged, whether any guardrails were added, and the new archive path.
