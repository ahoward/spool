# Decisions

Flat, append-only (newest at top). One entry per key decision. Dated.

## 2026-04-26 — spool stays Markdown-only at v0; non-Markdown patterns deferred (#2)

After surveying ~17 dev-agent tools for "perfect memory" approaches (Aider, Cline, Roo, Continue, Cursor, Copilot Workspace, OpenHands, Devin, Sweep, Goose, MemGPT/Letta, Voyager, Reflexion, plus Claude-side surface and AGENTS.md), the v0 stance is unchanged: spool is Markdown-only, in-repo, with `git grep` as the retrieval system. Three patterns flagged as "reconsider only if egregiously good" (embedding-based playbook retrieval, event-stream replay, spec-regenerates-plan) — all deferred until observed need.

**Considered alternatives:**
- Adopt vector-store memory (MemGPT/Letta) — lost: requires DB and runtime, violates Markdown-only. The repo + git grep is the retrieval system by design.
- Adopt auto-mutating memory (Cursor Memories, auto-/memory) — lost: background writes to a hidden file undermine "single source of truth in the repo." Promotion-on-close is the *reason* memory is trustworthy.
- Adopt plan-DAG with re-planning (Devin, OpenHands) — lost: a linear checklist suffices for issue-scoped work, and DAG implies parallelism which spool explicitly rejects.
- Adopt sub-recipes / sub-agents with isolated memory (Goose sub-recipes, OpenHands delegation) — lost: reintroduces the parallelism and hidden-state problems spool exists to avoid.

Six "Adopt now" recommendations from the analysis shipped as #5–#9 across PRs #10 and #11. See [archived analysis.md](../gh/issue/archive/2-perfect-memory-research/analysis.md) for full reasoning and source links.

## 2026-04-26 — --yolo skips prompts, not discipline; close --yolo leans on git (#3)

Headless mode is per-invocation (`--yolo`), off by default, never persisted. It skips user-prompts but preserves every other piece of spool discipline: commit protocol, serial constraint, one-step-per-commit, same-commit README updates. `close --yolo` originally refused on ambiguous promotion or `Status != done`, but was loosened to instead skip-and-log: git makes every close step a reversible commit, so refusing is unnecessarily strict.

**Considered alternatives:**
- Persistent setting (env var or settings.json) — lost because "set and forget" undermines the "I know what I'm doing" promise of the flag. Per-invocation is hostile to drift.
- Strict `close --yolo` (refuse on any ambiguity) — lost after follow-on decision. Git is version control; refusal is unnecessary because every step is reversible.
- Pure auto everywhere with no audit — lost because losing the trail of *what* got auto-decided makes the flag opaque. The `## Headless decisions` log preserves it.

## 2026-04-26 — playbooks are plain Markdown, not parameterised (#9)

`spool/playbooks/<name>.md` are short freeform CommonMark — a paragraph and a numbered list. Deliberately *not* a config format. The reason: AGENTS.md's plain-CommonMark stance is the right one for in-repo agent surfaces. Parameters create a configuration burden that erodes the "read it and you understand it" property. If a playbook needs configuration, it's not a playbook — it's a tool.

**Considered alternatives:**
- Goose-style YAML recipes with parameters — lost because parameters require an interpreter, which violates Markdown-only.
- Front-matter for metadata (tags, scope) — lost because grep over filenames+headings is sufficient at v0 library size, and metadata invites tooling we don't want yet.

## 2026-04-26 — close ritual step 2 made imperative (#12)

Reshaped close.md step 2 (Promote to evolving specs) into mandatory 2a/2b/2c sub-steps with imperative language ("Read the actual files. Do not draft from conversation memory."). Spool is normally advisory, but the failure mode here is silent (wrong-on-day-one docs surviving close), and silent failures need imperative guardrails. The imperative tone matches pickup's "confirm Next" gate, which is the existing precedent for non-negotiable steps.

**Considered alternatives:**
- Pure advisory ("consider reading the source files") — lost because the failure mode in #12 was *exactly* the advisory tone being ignored. Stronger language is the fix.
- Hard refusal (block close until source files are read) — lost because spool is advisory by design and we have no mechanism to verify reads. Imperative-but-unenforced is honest about the tradeoff.
