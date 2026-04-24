# Shared helpers. Sourced by tests. Not a standalone script.
# Each test calls `setup_repo` at the top; tmpdir + cd + git init happen there.
#
# Resolve SKILL_DIR at source time, BEFORE any cd to a tmp dir. $TEST_SCRIPT
# may be a relative path, so we must `cd` from the original cwd to get its
# absolute location.
SKILL_DIR=$(cd "$(dirname "$TEST_SCRIPT")/.." && pwd)
export SKILL_DIR

setup_repo() {
    tmp=$(mktemp -d)
    cd "$tmp"
    git init -q -b main
    git config user.email "test@example.com"
    git config user.name "Test"
    git commit --allow-empty -q -m "init"
}

cleanup_repo() {
    cd /
    rm -rf "$tmp"
}

assert_dir() {
    [ -d "$1" ] || { echo "expected dir: $1" >&2; exit 1; }
}

assert_no_dir() {
    [ ! -d "$1" ] || { echo "expected no dir: $1" >&2; exit 1; }
}

assert_file() {
    [ -f "$1" ] || { echo "expected file: $1" >&2; exit 1; }
}

assert_contains() {
    grep -qF "$2" "$1" || { echo "expected '$2' in $1" >&2; cat "$1" >&2; exit 1; }
}

# Re-implement the init subcommand's core scaffolding in shell so we can test
# the mechanics deterministically. Mirrors commands/init.md steps 1-3.
spool_init() {
    tracker=$1
    id=$2
    slug=$3
    title=$4
    url=$5
    branch=$6

    mkdir -p spool/docs spool/agents "spool/$tracker/issue/archive"
    [ -f spool/README.md ] || echo "# spool (this project)" > spool/README.md
    [ -f spool/agents/decisions.md ] || printf '# Decisions\n\nFlat, append-only (newest at top).\n' > spool/agents/decisions.md
    [ -f spool/agents/guardrails.md ] || printf '# Guardrails\n\nAgent failure modes.\n' > spool/agents/guardrails.md

    dir="spool/$tracker/issue/$id-$slug"
    if [ -d "$dir" ]; then
        echo "already exists: $dir" >&2
        return 1
    fi
    for existing in "spool/$tracker/issue/archive/$id-"*; do
        [ -e "$existing" ] || continue
        echo "already closed in archive: $existing" >&2
        return 1
    done

    mkdir -p "$dir"
    tmpl="$SKILL_DIR/templates/issue-readme.md"
    sed \
        -e "s|{{TITLE}}|$title|" \
        -e "s|{{TRACKER_URL}}|$url|" \
        -e "s|{{BRANCH}}|$branch|" \
        "$tmpl" > "$dir/README.md"
}

# Mirrors commands/close.md step 5 — the archive move.
spool_archive() {
    tracker=$1
    id=$2
    slug=$3
    mkdir -p "spool/$tracker/issue/archive"
    git mv "spool/$tracker/issue/$id-$slug" "spool/$tracker/issue/archive/$id-$slug"
}

# Mirrors commands/run.md §Decision tree step 2.
# Given a tracker + id, print one of: "pickup", "archived", "init".
# Callers assert on the printed token.
spool_run_decide() {
    tracker=$1
    id=$2
    active=$(find "./spool/$tracker/issue" -maxdepth 1 -type d -name "$id-*" ! -path '*archive*' 2>/dev/null | head -n1)
    archived=$(find "./spool/$tracker/issue/archive" -maxdepth 1 -type d -name "$id-*" 2>/dev/null | head -n1)
    if [ -n "$active" ]; then
        echo "pickup"
    elif [ -n "$archived" ]; then
        echo "archived"
    else
        echo "init"
    fi
}
