# /spool init

**Invocation:** `/spool init <tracker> <id> <slug>`

Scaffold a new issue working dir.

## Args

- `<tracker>` — `gh`, `linear`, `jira`, etc. Required. If missing, ask.
- `<id>` — issue id as used by the tracker (`42`, `ENG-17`). Required. If missing, ask.
- `<slug>` — short kebab-case name for the work. Required. If missing, suggest one from the tracker title if known, else ask.

## Steps

### 1. Bootstrap `./spool/` if absent

If `./spool/` does not exist, create the baseline layout. Ask the user to confirm once before creating, then:

```bash
mkdir -p spool/docs spool/agents spool/<tracker>/issue/archive
[ -f spool/README.md ] || cat > spool/README.md <<'EOF'
# spool (this project)

Project-local conventions for spool. See the root project README for the spool convention itself.
EOF
[ -f spool/agents/decisions.md ] || cat > spool/agents/decisions.md <<'EOF'
# Decisions

Flat, append-only (newest at top). One entry per key decision. Dated.
EOF
[ -f spool/agents/guardrails.md ] || cat > spool/agents/guardrails.md <<'EOF'
# Guardrails

Agent failure modes — things to stop re-proposing. Short by design.
EOF
```

### 2. Refuse if the issue dir already exists

```bash
dir="spool/<tracker>/issue/<id>-<slug>"
[ -d "$dir" ] && { echo "already exists: $dir"; exit 1; }
# Also check archive — refuse if closed-but-archived with this id.
ls spool/<tracker>/issue/archive/<id>-* 2>/dev/null && { echo "already closed in archive"; exit 1; }
```

Surface the error to the user; do not overwrite.

### 3. Create the issue dir and seed the README

```bash
mkdir -p "spool/<tracker>/issue/<id>-<slug>"
```

Read `./.claude/skills/spool/templates/issue-readme.md`, substitute:

- `{{TITLE}}` — ask the user for a one-line title (or derive from tracker if fetched).
- `{{TRACKER_URL}}` — ask the user, or construct from tracker+id if a convention is known (e.g., `https://github.com/<owner>/<repo>/issues/<id>` — only if the user confirms the owner/repo).
- `{{BRANCH}}` — ask the user, or suggest `<type>/<slug>` and let them edit.

Write the result to `spool/<tracker>/issue/<id>-<slug>/README.md`.

### 4. Prompt for Next

Ask the user for the single immediate next concrete action, write it into the `## Next` section.

### 5. Report

Tell the user where the dir was created and what Next is. Do not commit — that's the user's call, and the first real commit will happen during a pickup.
