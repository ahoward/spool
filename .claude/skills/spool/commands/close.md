# /spool close

**Invocation:** `/spool close <id>` (with optional `<tracker>:` prefix on `<id>`).

Walk the five-step promotion ritual. Interactive — ask before each step.

## Steps

### 1. Resolve and sanity-check

Find the issue dir: `find ./spool/<tracker>/issue -maxdepth 1 -type d -name "<id>-*"`. If not found or already under `archive/`, tell the user and stop.

Read the issue README. If `Status:` is not `done`, ask the user to confirm they really want to close anyway.

### 2. Promote to evolving specs

This step has three sub-steps in order. Do not skip 2a — it is the single biggest source of bad promoted docs.

#### 2a. Scan existing docs for staleness — BEFORE asking the user

List every file under `./spool/docs/`. Read each one (they are short by convention). For each, check whether what shipped in this issue **supersedes or contradicts** the existing content. Surface any conflicts to the user explicitly:

> `spool/docs/api.md` says "uses iron-session for auth," but issue #75 replaced iron-session with Web Crypto. This file is stale.

Do this **before** asking the open-ended "which files should reflect what shipped?" question. The user may not know what already exists or what just got superseded; the scan is the agent's job, not the user's.

#### 2b. Ask the user — informed by the scan

Ask: **which `./spool/docs/<subsystem>.md` file(s) should reflect what shipped?** Pre-populate the list with anything you flagged as stale in 2a, plus any net-new subsystem the user names.

#### 2c. Draft from code, not from memory

For each named file:

- **Read the actual shipped code first.** Open the files the issue's commits touched. Do not draft from conversation memory or the issue README's `## Done` summaries — both are lossy and framing-dependent.
- If the file exists, read it too. Propose merged content describing what *is* now.
- If it's new, draft it from scratch — but still from code, not from conversation.

Show the proposed spec content to the user for approval. Apply edits once approved.

Principles (from the project README):

- Describe what *is*, not what's planned. Aspirational content stays out.
- Subsystem granularity — one file per "thing you'd want to read to understand how X works."
- **Draft from code, not from conversation.** Conversation memory is lossy; the source files are authoritative.

### 3. Log decisions

Ask the user: **any key decisions from this issue worth logging?** For each, append an entry to `./spool/agents/decisions.md` using the template at `templates/decision-entry.md`.

For each decision, also ask: **what alternatives were considered, and why did each lose?** Capture them under a `**Considered alternatives:**` block. Skip the block when no real alternatives existed.

Insert at the top of `decisions.md` (newest-first). Use today's date (the actual date, not a placeholder — resolve via `date +%Y-%m-%d`).

### 4. Update guardrails if needed

Ask: **did any agent fail in a way the team should know about?** For each new guardrail, append a line to `./spool/agents/guardrails.md` using the template. Keep it short.

If the issue's `## Pitfalls` section uses the per-attempt structure (`### Attempt N` with `Tried:`/`Failed because:`/`Next attempt should:`), prefer the **"Next attempt should..."** line as the guardrail text — that's the actionable part. Fall back to a flat one-line summary for incidental Pitfalls without the structure.

### 4.5. Promote any new playbooks

Ask: **is any pattern from this issue worth reusing?** If yes, write or update `./spool/playbooks/<name>.md` — a short recipe (paragraph + numbered list). Skip if nothing recurring came up.

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
