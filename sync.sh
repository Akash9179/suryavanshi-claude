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

# 4. Drift check: warn when the shared portions of live settings diverge from
#    settings.shared.json (deny rules, plugins, marketplaces, effort). The live
#    file may hold EXTRA machine-personal keys (model, tui, notifications) —
#    only the shared keys are compared. Warning only; nothing is auto-changed.
if [ -f "$HOME/.claude/settings.json" ] && [ -f "$REPO/settings.shared.json" ]; then
  python3 - "$REPO/settings.shared.json" "$HOME/.claude/settings.json" <<'PY' >&2 || true
import json, sys
shared = json.load(open(sys.argv[1])); live = json.load(open(sys.argv[2]))
drift = []
for key in ("permissions", "enabledPlugins", "extraKnownMarketplaces", "effortLevel", "hooks"):
    if key in shared and shared[key] != live.get(key):
        drift.append(key)
if drift:
    print(f"sync: DRIFT between settings.shared.json and ~/.claude/settings.json in: {', '.join(drift)} — reconcile and commit suryavanshi-claude.")
PY
fi
