# Analysis: 'perfect memory' & long-running workflows in dev-agent tools

## Tools surveyed

### Coding-agent CLIs / IDEs

**Aider.** Builds a [tree-sitter repo map](https://aider.chat/docs/repomap.html) ranked by a graph algorithm so the model sees only the most call-graph-relevant symbols. Persists chat history under `~/.aider`, supports a user-supplied [conventions file](https://aider.chat/docs/usage/tips.html) loaded as system context. Scope: per-project (conventions) + per-session (history). Update model: append-only chat log; conventions overwritten manually. The repo map is computed, not stored as Markdown — it is regenerated per turn.

**Cline.** Ships the [Memory Bank](https://docs.cline.bot/features/memory-bank) pattern: a fixed set of Markdown files (`projectbrief.md`, `productContext.md`, `activeContext.md`, `systemPatterns.md`, `techContext.md`, `progress.md`) under `memory-bank/`, all read at the start of every task. Plan/Act mode pair gates writes. Scope: per-project. Update: file-overwrite, ritualized at session boundaries.

**Roo Code.** Fork-descendant of Cline. Adds [custom modes](https://docs.roocode.com/features/custom-modes) and a `.roo/rules-{mode}/` directory of Markdown rules concatenated alphabetically into the system prompt. "Sticky models" remember the last model per mode. Same Memory-Bank shape as Cline, with mode-scoped rule sub-directories. Scope: per-project, mode-segmented.

**Continue.dev.** [Rules](https://docs.continue.dev/customize/deep-dives/rules) live in `.continue/rules/` and apply to Agent/Chat/Edit. [Context providers](https://docs.continue.dev/customize/deep-dives/custom-providers) are pluggable `@`-mentions (files, diffs, terminal output, MCP). Scope: per-project for rules; per-turn for context. Update: edit-in-place rule files; no journal.

**Cursor.** Two layers: legacy `.cursorrules` (single file) and the new `.cursor/rules/*.mdc` directory with glob-scoped rule files ([docs](https://docs.cursor.com/context/rules)). The auto-generated [Memories](https://docs.cursor.com/context/memories) feature stores per-project facts the model proposes and the user approves — stored server-side, not in the repo. Scope: rules per-project; Memories per-project but out-of-tree.

**GitHub Copilot Workspace.** A [task → spec → plan → build](https://githubnext.com/projects/copilot-workspace/) waterfall. Spec and plan are first-class, editable artifacts; editing upstream regenerates downstream. Scope: per-task. Update: re-derivation, not append. Artifacts live in the Workspace UI, not as repo files. The spec/plan promotion idea is conceptually close to spool's docs/decisions promotion.

**OpenHands (formerly OpenDevin).** Agent state is an [event stream](https://arxiv.org/html/2407.16741v3) of actions and observations; [micro-agents](https://docs.all-hands.dev/usage/prompting/microagents-overview) are small Markdown prompts (often triggered by keyword) that augment the system prompt for specific tasks. Multi-agent delegation is built-in. Scope: per-session event stream + per-repo micro-agents in `.openhands/microagents/`. Update: event-sourced (append-only) + Markdown rules.

**Devin.** Public material describes a [DAG-shaped plan](https://docs.devin.ai/work-with-devin/interactive-planning) with dynamic re-planning, a planner/coder/critic split, and a memory layer combining vector snapshots of code with a replay timeline of commands and diffs ([Devin 2.0](https://cognition.ai/blog/devin-2)). Scope: per-session plan; per-org "Knowledge" notes that are repo-adjacent but stored in Devin, not Markdown. Update: re-planning + append-only timeline.

**Sweep.** Issue-driven: a GitHub issue is the unit of work; Sweep reads the issue, searches the codebase via embeddings, and opens a PR ([overview](https://www.sweep.io/)). Scope: per-issue. Update model: one-shot — no persistent per-issue scratchpad survives between runs; the issue body and PR are the artifacts. Closest in *workflow* to spool but discards the working notes.

**Goose (Block).** Sessions are persistent but ephemeral; [Recipes](https://block.github.io/goose/docs/guides/recipes/) are reusable YAML packages of extensions, prompts, and parameters. Sub-recipes run in isolation (no shared memory). A separate `memory` extension stores tagged user-facts. Scope: per-session sessions; global recipes; tag-scoped memory. Update: append/overwrite via tool calls.

### Claude-side

**CLAUDE.md ecosystem.** Per-repo (and per-user `~/.claude/CLAUDE.md`) Markdown loaded as system context every session. Convention is now overlapping with `AGENTS.md`. Scope: per-project + global. Update: hand-edited; meant for "always-true" facts, not journal.

**Claude Code memory, plan mode, slash commands, skills.** [`/memory`](https://code.claude.com/docs/en/memory) edits a `MEMORY.md` Claude maintains itself; `/plan` gates a read-only planning phase; [skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) are Markdown files with YAML front-matter under `.claude/skills/` that auto-invoke on relevant prompts; slash commands are explicit Markdown entry points under `.claude/commands/`. Scope: project + user. Update: a mix of append (auto memory) and overwrite (skills).

**AGENTS.md.** Cross-vendor convention ([agents.md](https://agents.md), [GitHub blog](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)). Single capitalised CommonMark file (nested copies allowed in monorepos), no front-matter, semantic headings (`## Build & Test`, `## Code Style`). Read by Codex, Cursor, Copilot, Gemini CLI, Factory, Ona, etc. Scope: per-repo. Update: hand-edited.

### Research / library patterns

**MemGPT / Letta.** [Three-tier memory](https://arxiv.org/abs/2310.08560) — core (in-context), recall (searchable history), archival (vector store) — managed via tool calls the model issues itself. Scope: per-agent. Update: event-sourced with self-edits. Requires a runtime + DB; not Markdown-portable.

**Voyager.** [Skill library](https://voyager.minedojo.org/) of executable JS that grows as the agent solves Minecraft tasks; new tasks retrieve relevant prior skills. Scope: cross-task, per-agent. Update: append-only, retrieval by similarity. Markdown-shaped analog: a library of *playbooks* keyed by task pattern.

**Reflexion.** [Verbal RL](https://arxiv.org/abs/2303.11366): after a failed trial the agent writes a short reflection; the reflection is prepended to context for the next attempt. Scope: per-task across attempts. Update: append-only short notes. Maps directly onto a guardrails / pitfalls pattern.

## Patterns

**1. Flat per-project rules file.** AGENTS.md, CLAUDE.md, `.cursorrules`, Aider conventions file, Continue rules. Always-true facts; hand-edited; no journal. Spool already uses this implicitly via `spool/README.md` and `docs/`.

**2. Per-session journal / scratchpad.** Aider chat log, OpenHands event stream, Goose session, Devin replay timeline. Append-only narrative of what happened. Spool's issue `README.md` (Status / Done / Next) plus the `<scratch>/` dir is the same shape, just durable past the process.

**3. Mode-segmented rules.** Roo Code `.roo/rules-{mode}/`, Continue rule globs, Cursor `.mdc` rule globs. One ruleset per task-archetype, loaded conditionally.

**4. Plan tree (Devin-style DAG).** Devin, Copilot Workspace (linear plan), OpenHands planner. Plan is a structured artifact, regenerable, with re-planning on failure. Requires either a runtime or a disciplined Markdown schema.

**5. Hierarchical / virtual memory.** MemGPT/Letta, Devin's vector + timeline. Demands a vector store and tool-driven self-edits. Not Markdown-portable.

**6. Skill library.** Voyager, Goose Recipes, Claude Code Skills, OpenHands micro-agents. A directory of named, retrievable, self-contained capabilities that grow over time.

**7. Self-reflection / pitfalls log.** Reflexion, Cline `activeContext.md`, Cursor Memories. Short append-only notes capturing "what went wrong, do this next time." Spool's `agents/guardrails.md` already implements this.

**8. Issue-scoped working dir.** Spool itself, Sweep (transient), Copilot Workspace tasks (ephemeral). The unit of memory is the issue.

**9. Spec promotion ritual.** Copilot Workspace (spec → plan → code), spool's promotion-on-close. Rare; most tools skip it.

**10. Memory Bank fixed-shape file set.** Cline, Roo Code, Roo-advanced-memory-bank. Six-or-so Markdown files with prescribed names and roles, re-read at every task start.

## Recommendations for spool

### Adopt now (Markdown-only)

- **Add an `AGENTS.md` shim at repo root that points to `spool/`.** One short paragraph: "This repo uses spool. Read `spool/README.md` and any active `spool/<tracker>/issue/*/README.md`." Costs nothing, makes spool legible to Codex, Copilot, Cursor, Factory, Ona — every AGENTS.md consumer. Pure interop win.

- **Standardise an issue-README skeleton with explicit Reflexion-style sections.** The current Status/Done/Next/Deferred/Pitfalls/Open-Questions shape is good; promote `Pitfalls` into a per-attempt append-only sub-list ("Attempt 1: tried X, failed because Y") rather than a flat bag. This is verbatim Reflexion, costs zero infra, and feeds `agents/guardrails.md` at promotion time.

- **Add a `playbooks/` dir to the spool convention.** Voyager-style skill library, but Markdown: `spool/playbooks/<name>.md`, each a short recipe ("How we add a new tracker adapter", "How we close an issue"). Promoted from issue dirs the same way `docs/` is. This is exactly the Cline/Roo "rules" pattern minus the JSON config and minus mode-segmentation. The Claude Code skill can grep `spool/playbooks/` for keyword matches in issue titles.

- **Add a `## Plan` section to the issue README template.** Not a DAG — a flat ordered list with checkboxes. This gives Copilot-Workspace-style plan/build separation without leaving Markdown, and `/plan` mode in Claude Code can populate it directly.

- **Codify the "read on resume" ritual in the Claude Code skill.** Cline's main contribution is *enforcement*: at every task start, read the memory bank. Spool's skill should refuse to start work until it has (a) read `spool/README.md`, (b) read the active issue README, (c) read `agents/decisions.md` and `agents/guardrails.md`. One prompt-line in the skill, large reliability gain.

- **Add a `decisions.md` entry template with a "considered alternatives" field.** AGENTS.md best-practice writeups all flag this as the highest-value section. One bullet per alternative, one line on why it lost. Costs nothing; prevents re-litigation in later issues.

### Reject (out of scope)

- **Vector-store memory (MemGPT/Letta, Devin's snapshots, Sweep's embeddings).** Requires a DB and a retrieval tool. Violates "Markdown-only, in-repo." The repo's own `git grep` over `spool/` is the retrieval system; that's the design.

- **Auto-mutating memory (Cursor Memories, Claude Code auto-`/memory`).** Background writes to a hidden file undermine "single source of truth in the repo." Spool's promotion-on-close is the *reason* memory is trustworthy — every change is a commit.

- **Mode-segmented rule directories (Roo Code, Cursor `.mdc` globs).** Adds a configuration surface (which mode? which glob?) for a workflow that is already serial-by-design. One issue dir, one set of rules, no modes.

- **Plan-DAG with re-planning machinery (Devin, OpenHands planner).** A linear checklist in the README is sufficient for issue-scoped work. A DAG implies parallelism, which spool explicitly rejects.

- **Sub-recipes / sub-agents with isolated memory (Goose sub-recipes, OpenHands delegation).** Reintroduces the parallelism and hidden-state problems spool exists to avoid.

- **YAML/front-matter recipe files (Goose recipes).** AGENTS.md's plain-CommonMark stance is the right one. Playbooks should be readable Markdown, not parameterised configs.

### Reconsider only if egregiously good

- **Embedding-based playbook retrieval.** Once `playbooks/` has 30+ entries, keyword grep gets noisy. A small embedding index over `spool/playbooks/*.md` with a CLI like `spool find-playbook "<query>"` would help. Cost: introduces a non-Markdown artifact (the index) and a dependency. Benefit: low until the library is large; defer until you observe the problem.

- **Event-stream replay (OpenHands-style).** A single `spool/<tracker>/issue/<id>/timeline.md` appended to on every commit (commit hash + one-line action) would reconstruct what happened post-hoc without reading git log. Cost: another file to maintain, partially redundant with `git log -- spool/<id>/`. Benefit: makes archived issues self-narrating without git tooling. Borderline; only worth it if archived issues are read by agents that don't have repo-history access.

- **Spec-regenerates-plan (Copilot Workspace style).** Editing `spool/docs/<subsystem>.md` could trigger an automatic refresh of open issues that reference it. Cost: requires a hook/runtime, not pure Markdown. Benefit: catches drift between specs and in-flight work. Worth it only if drift becomes a recurring failure mode.

## Notes on bugs/typos noticed

None observed in the README. The convention as documented is internally consistent.

## Sources

- [Aider repo map](https://aider.chat/docs/repomap.html)
- [Cline Memory Bank](https://docs.cline.bot/features/memory-bank)
- [Roo Code custom modes](https://docs.roocode.com/features/custom-modes)
- [Continue.dev rules](https://docs.continue.dev/customize/deep-dives/rules)
- [Continue context providers](https://docs.continue.dev/customize/deep-dives/custom-providers)
- [Cursor rules](https://docs.cursor.com/context/rules)
- [GitHub Copilot Workspace](https://githubnext.com/projects/copilot-workspace/)
- [OpenHands paper](https://arxiv.org/html/2407.16741v3)
- [Devin 2.0](https://cognition.ai/blog/devin-2)
- [Devin interactive planning](https://docs.devin.ai/work-with-devin/interactive-planning)
- [Sweep](https://www.sweep.io/)
- [Goose recipes](https://block.github.io/goose/docs/guides/recipes/)
- [Claude Code memory](https://code.claude.com/docs/en/memory)
- [AGENTS.md](https://agents.md)
- [GitHub blog: writing AGENTS.md](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [MemGPT paper](https://arxiv.org/abs/2310.08560)
- [Voyager](https://voyager.minedojo.org/)
- [Reflexion paper](https://arxiv.org/abs/2303.11366)
