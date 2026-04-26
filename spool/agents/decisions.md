# Decisions

Flat, append-only (newest at top). One entry per key decision. Dated.

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
