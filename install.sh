#!/usr/bin/env bash
# First-time setup of the suryavanshi-claude shared environment on this machine.
# Idempotent: safe to re-run.
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

echo "==> 1/5 Plugin marketplaces"
claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null || true
claude plugin marketplace add obra/superpowers-marketplace      2>/dev/null || true
claude plugin marketplace add forrestchang/andrej-karpathy-skills 2>/dev/null || true

echo "==> 2/5 Plugins"
for p in \
  superpowers@claude-plugins-official \
  vercel@claude-plugins-official \
  supabase@claude-plugins-official \
  playwright@claude-plugins-official \
  frontend-design@claude-plugins-official \
  firecrawl@claude-plugins-official \
  swift-lsp@claude-plugins-official \
  rust-analyzer-lsp@claude-plugins-official \
  claude-md-management@claude-plugins-official \
  claude-code-setup@claude-plugins-official \
  andrej-karpathy-skills@karpathy-skills ; do
  claude plugin install "$p" 2>/dev/null || true
done

echo "==> 3/5 gstack"
if [ ! -d "$CLAUDE_DIR/skills/gstack/.git" ]; then
  git clone https://github.com/garrytan/gstack.git "$CLAUDE_DIR/skills/gstack"
  echo "    gstack cloned — run its ./setup if it needs one."
else
  echo "    gstack already present."
fi

echo "==> 4/5 settings.json (deep-merged, non-destructive)"
SHARED="$REPO/settings.shared.json"
TARGET="$CLAUDE_DIR/settings.json"
if [ -f "$TARGET" ]; then cp "$TARGET" "$TARGET.bak.$(date +%s)" 2>/dev/null || true; fi
python3 - "$TARGET" "$SHARED" <<'PY'
import json, os, sys
target, shared = sys.argv[1], sys.argv[2]
def load(p):
    try:
        with open(p) as f: return json.load(f)
    except Exception: return {}
def merge(a, b):
    for k, v in b.items():
        if isinstance(v, dict) and isinstance(a.get(k), dict): merge(a[k], v)
        else: a[k] = v
    return a
base = load(target)
merge(base, load(shared))
with open(target, "w") as f: json.dump(base, f, indent=2)
print("    wrote", target)
PY

echo "==> 5/5 Shared CLAUDE.md import + skill links"
GLOBAL_MD="$CLAUDE_DIR/CLAUDE.md"
IMPORT_LINE="@$REPO/CLAUDE.md"
touch "$GLOBAL_MD"
if ! grep -qF "$IMPORT_LINE" "$GLOBAL_MD"; then
  printf '%s\n' "$IMPORT_LINE" | cat - "$GLOBAL_MD" > "$GLOBAL_MD.tmp" && mv "$GLOBAL_MD.tmp" "$GLOBAL_MD"
  echo "    added shared-practices import to $GLOBAL_MD"
fi

# Mark this as a receiver machine so the SessionStart hook auto-pulls here.
# (Source-of-truth machines skip install.sh, so they never get this marker.)
touch "$REPO/.autopull"
echo "    enabled auto-pull on this machine (.autopull marker created)"

bash "$REPO/sync.sh"

echo
echo "Done. Restart Claude Code so plugins, settings, and the SessionStart hook load."
