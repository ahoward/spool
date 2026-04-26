# Decisions

Flat, append-only (newest at top). One entry per key decision. Dated.

## 2026-04-26 — close ritual step 2 made imperative (#12)

Reshaped close.md step 2 (Promote to evolving specs) into mandatory 2a/2b/2c sub-steps with imperative language ("Read the actual files. Do not draft from conversation memory."). Spool is normally advisory, but the failure mode here is silent (wrong-on-day-one docs surviving close), and silent failures need imperative guardrails. The imperative tone matches pickup's "confirm Next" gate, which is the existing precedent for non-negotiable steps.

**Considered alternatives:**
- Pure advisory ("consider reading the source files") — lost because the failure mode in #12 was *exactly* the advisory tone being ignored. Stronger language is the fix.
- Hard refusal (block close until source files are read) — lost because spool is advisory by design and we have no mechanism to verify reads. Imperative-but-unenforced is honest about the tradeoff.
