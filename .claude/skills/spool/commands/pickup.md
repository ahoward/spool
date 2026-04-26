# /spool pickup

**Invocation:** `/spool pickup <ref>` where `<ref>` is an issue reference (e.g., `#42`, `gh:42`, `linear:ENG-17`).

The pickup protocol. This is the most important subcommand — it's the forcing function that prevents drift between sessions.

## Hard rules — repeated for emphasis

- **Confirm `Next` before editing any code.** Non-negotiable.
- **Do exactly one step.** End with a commit that updates the issue's `README.md`.
- **No parallel work.** No `git worktree`, no Agent sub-agents, no "step 3 and step 5 at once." One thread, one loose end.

## Steps

### 1. Resolve the issue dir

Parse `<ref>` into tracker + id. Defaults when ambiguous:

- `#N` or `N` → ask the user which tracker (`gh`, `linear`, etc.) unless only one tracker dir exists under `./spool/`.
- `gh:N`, `linear:KEY-N`, etc. → tracker is explicit.

Locate the working dir:

```bash
find ./spool/<tracker>/issue -maxdepth 1 -type d -name "<id>-*" 2>/dev/null
```

If no match, tell the user the issue isn't spooled and suggest `/spool init <tracker> <id> <slug>`. Do not create anything.

If the match is under `issue/archive/<id>-*/`, tell the user the issue was already closed and ask whether they want to reopen (which is out of scope for this subcommand — they'd need to move it back manually).

### 2. Read the spec

Open the tracker URL recorded in the issue README's `**Spec:**` line. Fetch it only if the user has granted network access (`WebFetch`); otherwise, tell the user you skipped it and ask them to paste any relevant updates.

### 3. Read the issue's `README.md`

This is the source of truth for state. Extract:

- `Status:` — in-progress / blocked / done.
- `Branch:` — verify it matches current branch; if not, warn the user.
- `## Done` — what's shipped.
- `## Next` — the immediate next action. **This is what you'll confirm with the user.**
- `## Plan` — the wider checklist for this issue, if present. Use it to keep `Next` consistent with the broader plan.
- `## Deferred`, `## Pitfalls`, `## Open questions` — load into context.

If any section is missing or malformed, note it but don't refuse to proceed (advisory mode).

### 4. Glance at specs + decisions

Read any `./spool/docs/<subsystem>.md` files mentioned in the issue README or the spec.
Read the top ~3 entries of `./spool/agents/decisions.md` (newest-first, so the first entries).

### 5. Glance at guardrails and playbooks

Read `./spool/agents/guardrails.md` in full. It's short by design.

Grep `./spool/playbooks/*.md` for keywords from the issue title and `## Next`. Read any matching playbook in full. Playbooks are short — a paragraph and a numbered list — so the cost is low and the value is high when a match exists.

### 6. Confirm `Next` with the user — **STOP HERE**

Surface a short message like:

> Picked up #42 on branch `feat/rate-limit`.
> README says Next is: **"Add per-user rate limit middleware to api/middleware/rate.ts."**
> Start there?

Wait for the user's answer. If they redirect, take the redirect as the new Next and do not update the README yet — let the upcoming commit do it.

### 7. Do exactly one step

Implement the confirmed Next. One commit at the end. The commit must:

- Subject: `<type>(<scope>): <what shipped>`.
- Body: one paragraph in the context of the issue.
- Footer: `Spool: spool/<tracker>/issue/<id>-<slug>/README.md` and `Refs: #<id>`.
- Update the issue's `README.md` in the same commit: move the just-finished step to `## Done` with commit sha placeholder (use `HEAD` after commit, or amend with the real sha post-commit if the user permits), and write the next concrete step into `## Next`.

Delegate the commit to `commands/commit.md` conventions.

### 8. Report back

Summarize in one or two sentences: what shipped, what Next now says. End.
