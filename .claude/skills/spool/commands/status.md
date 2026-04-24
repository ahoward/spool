# /spool status

**Invocation:** `/spool status`

List active spools across all trackers. Read-only; never edits.

## Steps

### 1. Find active working dirs

```bash
find ./spool -mindepth 3 -maxdepth 3 -type d -path '*/issue/*' ! -path '*/archive*' ! -name archive
```

This gives you `./spool/<tracker>/issue/<id>-<slug>/` paths only, excluding the `archive/` dir itself and anything inside it.

If none, report "no active spools" and stop.

### 2. For each dir, extract state

From each `README.md`, pull:

- First line (the `# <Title>` heading).
- `**Status:**` value.
- `**Branch:**` value.
- First non-comment line under `## Next`.

Advisory: if any of these are missing, flag the issue dir as malformed but keep listing.

### 3. Flag suspicious state

- `Status: done` but dir is *not* under `archive/` → flag as "done but not archived — run `/spool close`."
- `Status: blocked` → flag so the user sees it.
- Branch recorded in README doesn't exist in `git branch --list` → flag as "branch missing."

### 4. Report

One line per active spool. Keep it terse. Example:

```
gh/42-rate-limit   in-progress   feat/rate-limit   Next: Add per-user middleware to api/middleware/rate.ts
gh/51-docs-rewrite done          feat/docs         ⚠ done but not archived — run `/spool close 51`
linear/ENG-17-...  blocked       fix/eng-17        Next: (awaiting design review)
```

End.
