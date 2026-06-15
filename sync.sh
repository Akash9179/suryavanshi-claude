#!/usr/bin/env bash
# Pull latest shared config and (re)link custom skills into ~/.claude/skills/.
# Safe to run repeatedly. Invoked by the SessionStart hook on every launch.
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO/skills"
SKILLS_DST="$HOME/.claude/skills"

# 1. Pull latest, but only if a remote/upstream is configured. Never block startup.
if git -C "$REPO" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
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
    # Already a symlink — repoint it in case the repo moved.
    ln -sfn "$dir" "$link"
  elif [ -e "$link" ]; then
    # A real dir/file with this name already exists (e.g. a gstack skill). Don't clobber.
    echo "sync: skipping '$name' — a non-symlink already exists at $link" >&2
  else
    ln -s "$dir" "$link"
  fi
done
