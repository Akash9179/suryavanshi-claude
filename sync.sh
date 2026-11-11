#!/usr/bin/env bash
# Pull latest shared config, (re)link custom skills, and keep gstack's compiled
# runtime fresh. Safe to run repeatedly. Invoked by the SessionStart hook on
# every launch, so it stays fast: it only rebuilds gstack when something is
# actually missing or stale.
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO/skills"
SKILLS_DST="$HOME/.claude/skills"
GSTACK_DIR="$SKILLS_DST/gstack"
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"

# 1. Pull latest — ONLY on machines that opt in via a `.autopull` marker
#    (git-ignored, per-machine; receiver machines get it from install.sh).
#    A source-of-truth machine omits the marker, so it never pulls and its
#    setup is never disturbed from outside — changes there flow outward only.
if [ -f "$REPO/.autopull" ] && \
   git -C "$REPO" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git -C "$REPO" pull --rebase --autostash -q 2>/dev/null || true
fi

# 2. Link each skill folder into ~/.claude/skills/ (skip _-prefixed and README).
mkdir -p "$SKILLS_DST"
for dir in "$SKILLS_SRC"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  case "$name" in _*) continue ;; esac
  link="$SKILLS_DST/$name"

  if [ -L "$link" ]; then
    ln -sfn "$dir" "$link"               # already a symlink — repoint in case the repo moved
  elif [ -e "$link" ]; then
    echo "sync: skipping '$name' — a non-symlink already exists at $link" >&2
  else
    ln -s "$dir" "$link"
  fi
done

# 2b. Link each custom agent definition into ~/.claude/agents/.
AGENTS_SRC="$REPO/agents"
AGENTS_DST="$HOME/.claude/agents"
if [ -d "$AGENTS_SRC" ]; then
  mkdir -p "$AGENTS_DST"
  for file in "$AGENTS_SRC"/*.md; do
    [ -f "$file" ] || continue
    link="$AGENTS_DST/$(basename "$file")"
    if [ -L "$link" ]; then
      ln -sfn "$file" "$link"
    elif [ -e "$link" ]; then
      echo "sync: skipping agent '$(basename "$file")' — a non-symlink already exists at $link" >&2
    else
      ln -s "$file" "$link"
    fi
  done
fi

# 2c. Remove links that point into this repo at something no longer there
#     (a skill or agent that was deleted or renamed). Links to anywhere else
#     are never touched.
for dst in "$SKILLS_DST" "$AGENTS_DST"; do
  [ -d "$dst" ] || continue
  for link in "$dst"/*; do
    [ -L "$link" ] && [ ! -e "$link" ] || continue
    case "$(readlink "$link")" in
      "$REPO"/*) rm -f "$link" && echo "sync: removed stale link $(basename "$link")" >&2 ;;
    esac
  done
done

# 3. Keep gstack's runtime fresh. On receiver machines, `git pull` above can
#    advance gstack's sources without rebuilding the compiled browse/design/pdf
#    binaries — so /browse, /qa etc. would silently break. Rebuild only when the
#    binary is missing or older than a tracked source, and only if bun is here.
if [ -f "$REPO/.autopull" ] && [ -x "$GSTACK_DIR/setup" ] && command -v bun >/dev/null 2>&1; then
  bin="$GSTACK_DIR/browse/dist/browse"
  needs_build=0
  if [ ! -x "$bin" ]; then
    needs_build=1
  else
    # Rebuild if package.json or the lockfile is newer than the built binary.
    for src in "$GSTACK_DIR/package.json" "$GSTACK_DIR/bun.lock"; do
      [ -f "$src" ] && [ "$src" -nt "$bin" ] && needs_build=1
    done
  fi
  if [ "$needs_build" -eq 1 ]; then
    echo "sync: rebuilding gstack runtime (sources changed or binary missing)…" >&2
    ( cd "$GSTACK_DIR" && ./setup ) >/dev/null 2>&1 \
      && echo "sync: gstack rebuilt." >&2 \
      || echo "sync: gstack rebuild FAILED — run 'cd $GSTACK_DIR && ./setup' to see why." >&2
  fi
fi

# 4. Drift check: warn when this machine is missing something the shared
#    settings ask for. A machine may ADD its own plugins, marketplaces, allows
#    and hooks; drift-check.py holds the rules. Warning only, nothing changes.
if [ -f "$HOME/.claude/settings.json" ] && [ -f "$REPO/settings.shared.json" ] && [ -f "$REPO/drift-check.py" ]; then
  drift="$(python3 "$REPO/drift-check.py" "$REPO/settings.shared.json" "$HOME/.claude/settings.json" 2>&1)" \
    || echo "sync: $drift — reconcile and commit suryavanshi-claude." >&2
fi
