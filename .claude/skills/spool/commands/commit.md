# /spool commit

**Invocation:** `/spool commit`

Produce a commit that satisfies the spool commit protocol. Run this when finishing a pickup step (or anywhere you want a spool-shaped commit).

Not a replacement for the user's own commit discipline — a convenience that enforces the protocol.

## Protocol (from the project README)

Every commit on a spooled issue:

- **Subject:** `<type>(<scope>): <what shipped>`.
- **Body:** one paragraph in the context of the issue. Why this step, what's load-bearing, what tests pass.
- **Footer:** `Spool: spool/<tracker>/issue/<id>-<slug>/README.md` and `Refs: #<id>`.
- **Same commit updates the issue's README.md** — `Done` gets the new step, `Next` gets rewritten.

Reading `git log` for an issue should read as a narrative, not a pile of patches.

## Steps

### 1. Identify the active issue

Look for the issue dir matching the current branch:

```bash
git rev-parse --abbrev-ref HEAD  # current branch
grep -l "^\*\*Branch:\*\* *$BRANCH" spool/*/issue/*/README.md
```

If none matches, ask the user which issue this commit belongs to. If they say "none," fall back to a plain conventional commit — but tell them `/spool commit` isn't doing anything special.

### 2. Read the issue README

Capture the current `Done` and `Next` sections.

### 3. Ask the user

- What type (`feat`, `fix`, `chore`, `refactor`, `test`, `docs`) and scope?
- One-line "what shipped"?
- One-paragraph "why this step / what's load-bearing / tests"?
- What is the new `Next`?

Advisory check: if the user's "what shipped" doesn't obviously align with the README's current `Next`, flag it and ask whether the README should be updated first.

### 4. Update the issue README

- Append the just-shipped step to `## Done` as:
  `- [step N] <what shipped>. Commit: PENDING. Tests: <green|red|n/a>. Verified: <how>.`
  (The `PENDING` gets replaced with the real sha in step 6.)
- Replace `## Next` with the user-provided next action.
- If `## Plan` exists and contains an unchecked item that matches what just shipped, check it off (`[ ]` → `[x]`).

### 5. Stage and compose the commit

Stage the README update and any code changes the user has told you belong to this step:

```bash
git add spool/<tracker>/issue/<id>-<slug>/README.md <other files>
```

Compose the commit message:

```
<type>(<scope>): <what shipped>

<one-paragraph body>

Spool: spool/<tracker>/issue/<id>-<slug>/README.md
Refs: #<id>
```

Show the user the message and stage listing; ask for approval.

### 6. Commit, then backfill the sha

```bash
git commit -m "$MSG"
SHA=$(git rev-parse --short HEAD)
# Replace PENDING with $SHA in the README, amend:
sed -i "s/Commit: PENDING/Commit: $SHA/" spool/<tracker>/issue/<id>-<slug>/README.md
git add spool/<tracker>/issue/<id>-<slug>/README.md
git commit --amend --no-edit
```

The amend here is limited to the sha backfill on a commit the user just approved — this is the one case where amending is fine. If the user has configured a policy against amends, skip the amend and leave `PENDING` in place with a note.

### 7. Report

Print subject + sha. End.

## Headless mode

`/spool commit --yolo` derives commit metadata from context rather than asking:

- **Type** — parsed from the current branch name (`feat/...` → `feat`, `fix/...` → `fix`, `docs/...` → `docs`, `chore/...` → `chore`, `refactor/...` → `refactor`, `test/...` → `test`). If branch is `main` or otherwise unparseable, default to `chore`.
- **Scope** — the issue's tracker+id (`spool/#<id>`) for spool-tracked work. If the diff is changing skill files specifically, prefer `skills/spool` (matches existing project conventions).
- **What shipped** — derived from the staged diff: pick the most-changed file's basename plus a short verb composed from the diff content. This is best-effort; under `--yolo` the user is trading precision for speed.
- **Body** — generate a 1-3 sentence body summarizing what changed and why, referencing the issue and Next.
- **README update** — automatic. Append the just-shipped step to `## Done` with the same advisory check (does the change roughly match Next?). The check still runs but logs a warning to `## Headless decisions` rather than prompting.

The sha-backfill amend (step 6) still runs.

If the staged diff is empty, refuse — there's nothing to commit.
