# spool

**Serial multi-session work via linked artifacts — a filesystem convention for agents and teams.**

## The problem

AI coding sessions die. Context gets compacted (nuance dropped) or conversations end and new ones start. When the user says "do #42" three days later, future-agent wakes up with:

- Whatever files it thinks to read.
- The current git state.
- No memory of the conversation that produced the design, the rejected alternatives, or the half-finished commit it was about to make.

Without a deliberate handoff structure, future-agent (or a new team member) either:

1. **Re-litigates settled decisions** — proposes things already killed.
2. **Implements the wrong shape** — trusts stale code over newer intent.
3. **Loses its place** — can't tell what's done, pending, or broken.
4. **Branches off in parallel** — starts a second thread because it can't see the first.

spool prevents all four. It is a filesystem convention inside your repo that gives every multi-session piece of work a live working directory, a promotion path into long-lived specs, and a frozen archive at close.

## The name

A spool is serial by construction. You wind work onto it in order; you unwind it off in order. There is one loose end at any time — the pickup point. No parallel threads.

## Layout

Everything spool-related lives under `./spool/` in your project. Top-level:

```
./spool/
  README.md                    # what spool is in this project, any local conventions
  docs/                        # evolving specs, one per subsystem
    <subsystem>.md
    ...
  agents/                      # agent-related state (not project state)
    decisions.md               # flat, dated log of key decisions
    guardrails.md              # agent behavioral guardrails — Claude, Gemini, any
  playbooks/                   # short reusable recipes — "how we do X"
    <name>.md                  # one playbook per recurring task pattern
  gh/                          # GitHub-tracked issues
    issue/
      <id>-<slug>/             # live working dir
        README.md              # state: Done/Next/Deferred/Pitfalls
        <scratch>              # research, drafts, adversarial reviews
      archive/
        <id>-<slug>/           # closed issues, moved intact
          README.md
          <whatever>
  linear/                      # Linear-tracked issues, same shape
    issue/
      <id>-<slug>/
        README.md
  <other trackers>/            # Jira, etc., same shape
```

The tracker namespace (`gh/`, `linear/`, etc.) is explicit in the path because not every project uses the same tracker. Issues from multiple trackers coexist without collision.

## Why `./spool/` at root, not `tmp/spool/` or `docs/spool/`

Spool is *state*, not documentation. Active issue dirs are mutable working memory; `decisions.md` is a permanent journal; the archive is a frozen audit trail. None of that fits under `docs/` semantically — a project's own `docs/` is for product/architecture documentation, and nesting spool there reads as "documentation about spool" rather than "the spool of work-in-flight." `tmp/` is worse — it implies disposable, which inverts the durability spool guarantees.

The deeper reason is **the path is the convention**. Commit footers write `Spool: spool/gh/issue/42-foo/README.md`. AGENTS.md tells external tools to read `spool/`. Tracker references and cross-team handoffs all assume the same fixed path. A reader three years from now should be able to `cat` the path from a commit footer and find the file. That contract requires the path be predictable across every clone of every spooled project.

Hence: **`./spool/` at the project root, not configurable.** Spool claims one piece of root namespace and uses it consistently. If a project already has a `spool/` directory for something else, rename that other thing; a hard collision with the spool convention is one-time pain and the alternative (per-project path overrides) breaks the predictability that makes spool work.

## The five kinds of files

### 1. Issue working dirs — `./spool/<tracker>/issue/<id>-<slug>/`

The *state* of one in-progress piece of work. Mutable. Overwritten as work progresses. Moved to `archive/` on close.

Every issue dir contains a `README.md` with these sections:

```markdown
# <Issue title>

**Spec:** <tracker URL>
**Status:** in-progress | blocked | done
**Branch:** <branch-name>

## Done
- [step N] <one line>. Commit: <sha>. Tests: <green|red|n/a>. Verified: <how>.

## Next
<the single immediate next concrete action — not the whole roadmap>

## Deferred
- <thing>: <one-line reason it was cut from this session>

## Pitfalls
- <surprise hit during the work> — <how to avoid it>

## Open questions
- <thing punted on, needs user input>
```

Beyond `README.md`, the issue dir can hold anything the work needs: scratch notes, research dumps, adversarial review transcripts, sketches. Scoped to the issue, moved to archive when it closes.

### 2. Evolving specs — `./spool/docs/<subsystem>.md`

Long-lived. One file per subsystem of the project. These are the *current state of truth* — what actually exists, how it actually works, today.

Updated when issues close by merging in what was decided. Over time, these become the canonical "here's how X works" documents. A new contributor reads `./spool/docs/<subsystem>.md` and knows how that subsystem works without having to dig through issues.

Principles:
- Describe what *is*, not what's planned. Aspirational content belongs in issues.
- Updated only on issue close, as part of the promotion step.
- Subsystem granularity — one file per "thing you'd want to read to understand how X works." New subsystems get new files as they emerge.

### 3. Agent decisions log — `./spool/agents/decisions.md`

Flat, append-only (newest at top). One entry per key decision. Dated.

Format:

```markdown
## 2026-04-23 — <short headline> (#<issue>)

<One-paragraph why: the reasoning behind the choice, the alternatives considered, the context that made this the right answer.>
```

Why separate from evolving specs: specs describe current truth; decisions log explains *why*. The spec says "fib scale." The decision says "fib because linear clusters." Future work wanting to revisit the choice finds the reasoning.

Dates are critical — they pin the decision to its context. A decision made in April may not survive a full rewrite in October, and the date makes staleness detectable.

### 4. Agent guardrails — `./spool/agents/guardrails.md`

In-repo, visible to the team. Contains *agent failure modes* — things an agent will keep re-proposing that have been rejected, terminology drift, shortcuts that bite.

Why in-repo (not in `~/.claude/.../` or equivalent): team collaboration, multi-agent reality. Multiple humans might work with multiple agents on this project. Each local agent-memory dir is separate; the repo is the shared surface. If any agent needs a guardrail, the whole team and every agent should see it.

Format: bullet list grouped by agent (or shared), one line per guardrail, plus a short "why." Short on purpose.

### 5. Playbooks — `./spool/playbooks/<name>.md`

Long-lived. One file per recurring task pattern — "how we add a tracker adapter," "how we close an issue," "how we onboard a new dev." A small, growing skill library scoped to this project.

Read by `pickup` and `run` when the issue title or `Next` mentions a keyword that matches a playbook name. Promoted from issue dirs at close time when a pattern from the work is reusable — same lifecycle as `docs/`, but the unit is a recipe instead of a subsystem.

Principles:
- One playbook per "thing you'd want a recipe for the next time it comes up."
- Short — a paragraph or two and a numbered list, not a manual.
- Plain CommonMark. No front-matter, no parameters. If a playbook needs configuration, it's not a playbook.
- Promoted, not invented in flight. New playbooks land via the close ritual, where the work that justifies them has already shipped.

## The promotion ritual (issue close)

When an issue closes, the final PR does, as its last commit:

1. **Promote to evolving specs.** Update `./spool/docs/<subsystem>.md` to reflect what shipped. Replace or merge sections; this is the *new current truth*. **Draft from code, not from conversation memory** — read the actual shipped files. And **scan existing `docs/` for staleness** before drafting; an issue often supersedes content the user has forgotten about.
2. **Log the decisions.** Append dated entries to `./spool/agents/decisions.md` for any key choices worth remembering.
3. **Update guardrails if needed.** If an agent failed in a way the team should know about, add to `./spool/agents/guardrails.md`.
4. **Promote any new playbooks.** If a pattern from this issue is worth reusing, write or update `./spool/playbooks/<name>.md`. One paragraph + a numbered list, not a manual.
5. **Archive the issue dir.** `mv spool/<tracker>/issue/<id>-<slug>/ spool/<tracker>/issue/archive/<id>-<slug>/`. No tar, no gzip — just move. Git history preserves the rename.
6. **Commit.** `chore(spool): close #<id>, promote to docs/<subsystem>.md, archive`.

After merge:
- Specs carry design truth forward.
- Decisions log records the why.
- Archive dir is a browsable, linkable, grep-able frozen snapshot of the process.
- The issue body can link directly to archived files via standard blob URLs (use merge-commit SHA for permanence).

No memory outside the repo. No extracted archives. No hidden state.

## Pickup protocol

When the user says "do #42" (or any reference to a tracker ID with an active spool):

1. **Read the spec.** Open the issue in the tracker. Understand what's being built.
2. **Read the issue's `README.md`.** `./spool/<tracker>/issue/<id>-.../README.md` is the source of truth for state. Ignore stale impressions from the spec about progress.
3. **Glance at relevant specs + decisions.** `./spool/docs/<subsystem>.md` for current truth; `./spool/agents/decisions.md` for recent why-entries.
4. **Glance at `./spool/agents/guardrails.md` and `./spool/playbooks/`.** Skim guardrails before proposing; grep playbooks for keywords from the issue title or `Next`.
5. **Confirm the next action with the user before touching code.** "README says next is step 3 — start there?" Catches drift.
6. **Do exactly one step.** End with a commit that updates the issue's `README.md`.

Step 5 is non-negotiable. The whole methodology fails if an agent assumes state files are right and starts coding without checking.

## Commit protocol

Every commit on a spooled issue:

- Subject: `<type>(<scope>): <what shipped>`
- Body: one paragraph in the context of the issue. Why this step, what's load-bearing, what tests pass.
- Footer: `Spool: spool/<tracker>/issue/<id>-<slug>/README.md` and `Refs: #<id>`.
- The same commit updates the issue's `README.md` (Done + Next sections).

Reading `git log` for an issue should read as a narrative, not a pile of patches.

## Serial constraint

**One spool runs at a time per issue.** Within an issue, no parallel work — no `git worktree`, no spawning agents to do steps in parallel, no "I'll do step 3 and step 5 at once."

Why: parallel work fails in subtle ways. Overlapping edits create merge conflicts agents can't reason about. Split contexts produce inconsistent decisions. The spool *enforces* "do one thing, finish it, write it down, do the next thing."

Different issues can spool concurrently — they don't share state. But within one issue, one thread, one loose end.

## When to use spool

Use it when work is:
- Multi-session (more than one agent session to complete).
- Stateful (each step depends on previous).
- Easy to drift on (multiple plausible designs, decisions that get re-litigated).

Don't use it for:
- One-shot tasks ("rename foo to bar").
- Pure exploration ("look around the codebase and tell me what's there").
- Trivial serial work where commit messages alone are enough.

Cost: ~30 minutes upfront (create the issue dir + seed README) and ~5 minutes per commit (update the README). Benefit: future-agent and future-teammates don't waste sessions re-orienting.

## What's NOT in a spool

- Implementation details. Those live in the spec or in code.
- Conversation history. That lives in chat transcripts.
- Long reasoning. The decisions log is short; evolving specs are terse; guardrails are one-liners.
- Roadmaps of future work. The issue's `README.md` "Next" section is *one* thing, not a list. Use the spec for the full roadmap.

## Why this works

Three surfaces, three jobs, no overlap:

- **Tracker issues** are events — proposals, debates, decisions-in-flight.
- **`./spool/<tracker>/issue/<id>/`** is the working state — what's happening right now on this one piece of work.
- **`./spool/docs/` + `./spool/agents/`** are the merged truth — what has been decided, what currently exists, what guardrails matter.

Events flow into state (issue close → promotion). Agents read state before acting. Teams read state to onboard. The repo is the single source of truth; nothing lives in agent-vendor memory files where only one person can see it.

## Install

A Claude Code skill lives under `.claude/skills/spool/`. Two scopes, pick one.

**Per-project (recommended — matches "everything in the repo" ethos):**

```sh
cd <your-project>
git clone https://github.com/ahoward/spool /tmp/spool-src
mkdir -p .claude/skills
cp -r /tmp/spool-src/.claude/skills/spool .claude/skills/spool
rm -rf /tmp/spool-src
```

Commit `.claude/skills/spool/` into the project. The team gets the skill, reviews it, evolves it.

**Personal (available in every project):**

```sh
git clone https://github.com/ahoward/spool /tmp/spool-src
mkdir -p ~/.claude/skills
cp -r /tmp/spool-src/.claude/skills/spool ~/.claude/skills/spool
rm -rf /tmp/spool-src
```

**Verify:**

```sh
sh .claude/skills/spool/tests/run.sh   # or ~/.claude/... for personal scope
```

All tests should pass. In Claude Code, `/spool` should now list the subcommands.

## Update

The skill is Markdown-only; updating is "blow away the old tree, drop in the new." Spool's playbooks evolve upstream — local customizations are not the expected path. If you've forked behavior, treat it as a fork and merge manually.

**Per-project update:**

```sh
cd <your-project>
git clone https://github.com/ahoward/spool /tmp/spool-src
rm -rf .claude/skills/spool
cp -r /tmp/spool-src/.claude/skills/spool .claude/skills/spool
rm -rf /tmp/spool-src
sh .claude/skills/spool/tests/run.sh
```

Then commit the diff. Reviewing the diff *is* the update review — if a playbook changed in a way you don't want, revert that file before committing.

**Personal update:** same shape, with `~/.claude/skills/spool` instead.

Your project's `spool/` directory (issue dirs, decisions, guardrails, playbooks, archive) is untouched by either scope's update — only `.claude/skills/spool/` gets replaced.

## Commands

All invocations are explicit — the skill never fires on casual mentions of issue IDs.

**The one you'll use most:**

- `/spool run <ref>` — start or continue work on an issue. If the spool dir doesn't exist yet, scaffolds it; if it does, resumes it. Either way, confirms Next with you, does one step, commits.

**Primitives:**

- `/spool init <tracker> <id> <slug>` — scaffold a new issue working dir without starting work.
- `/spool pickup <ref>` — resume an existing spool. Fails if no dir exists.
- `/spool commit` — produce a commit that satisfies the spool commit protocol + updates the issue README in the same commit.
- `/spool close <id>` — walk the five-step promotion ritual: update specs, log decisions, update guardrails, archive, commit.
- `/spool status` — list active spools across trackers. Read-only.

See `.claude/skills/spool/SKILL.md` and `.claude/skills/spool/commands/*.md` for the full playbooks.

## Evolution

v0 is Markdown-only: playbooks + templates + inline bash. Advisory validation.

Likely v1 after dogfooding:

- Schema validation on the issue `README.md` so tools can parse it reliably.
- On-demand portable `bun` binary installed under `.claude/skills/spool/bin/` for logic that outgrows inline shell. No system-runtime assumptions.
- Release tarball / one-liner installer.

For now, it's discipline. The point of this repo is to lock in the concept before over-tooling it.

## Status

Pre-release. Concept is being dogfooded on [ahoward/joust](https://github.com/ahoward/joust) starting with issue #42. Expect churn.
