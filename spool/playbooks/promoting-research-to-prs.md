# Promoting research to PRs

When an issue produces an analysis document (a research deliverable, not a code change), promoting its recommendations into actual work means a multi-step fan-out. Done badly, recommendations evaporate or accumulate into one too-big PR. Done well, each recommendation becomes its own reviewable artifact that traces back to the source analysis.

## When to use

The originating issue produced a Markdown analysis doc with a "Recommendations" section split into buckets — typically *Adopt now*, *Reject*, *Reconsider only if X*.

## Steps

1. **Skim the analysis with the user.** Don't presume which recommendations to act on. Surface the buckets, get a yes/no on each "Adopt now" item.
2. **One issue per recommendation.** Even small ones. Each issue body links the source analysis (`spool/gh/issue/<id>-<slug>/analysis.md` or its archived path) so future-agent can find the reasoning cold.
3. **Group into PRs by cohesion, not by count.** Small adjacent template tweaks bundle naturally; convention changes get their own PR. The PRs reference all the issues they close.
4. **Close each issue ritually after merge.** No skipping the close ritual just because the change was small — that's how lessons evaporate.
5. **Log a meta-decision on the originating issue.** When closing the research issue itself, add a single decisions.md entry summarizing the *stance* the analysis crystallized (e.g., "spool stays Markdown-only at v0"), not just the individual adopt/reject calls. The stance is what future-agent needs to remember; the per-item calls are in the analysis doc.

## See also

- `.claude/skills/spool/commands/close.md` — the close ritual for individual issues.
- `spool/playbooks/closing-an-issue.md` — the close ritual condensed.
