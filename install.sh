#!/usr/bin/env bash
# First-time setup of the suryavanshi-claude shared environment on this machine.
#
# Idempotent and self-repairing: safe to re-run. It bootstraps prerequisites,
# installs plugins, clones AND BUILDS gstack (runs its ./setup), merges shared
# settings, wires the shared CLAUDE.md + auto-pull hook, and then VERIFIES the
# end state. It does NOT print "Done" unless the important pieces actually work.
#
# Exit code: 0 = everything critical is in place, 1 = one or more critical
# steps failed (details printed in the summary).
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
GSTACK_DIR="$CLAUDE_DIR/skills/gstack"
BUN_VERSION="${BUN_VERSION:-1.3.10}"
mkdir -p "$CLAUDE_DIR"

# ── Output helpers ────────────────────────────────────────────
if [ -t 1 ]; then BOLD=$'\033[1m'; RED=$'\033[31m'; GRN=$'\033[32m'; YEL=$'\033[33m'; DIM=$'\033[2m'; RST=$'\033[0m'
else BOLD=''; RED=''; GRN=''; YEL=''; DIM=''; RST=''; fi
step() { printf '\n%s==> %s%s\n' "$BOLD" "$*" "$RST"; }
ok()   { printf '    %s✓%s %s\n' "$GRN" "$RST" "$*"; }
warn() { printf '    %s!%s %s\n' "$YEL" "$RST" "$*"; }
err()  { printf '    %s✗%s %s\n' "$RED" "$RST" "$*"; }

FAILURES=()
WARNINGS=()
fail()    { err "$1"; FAILURES+=("$1"); }
softwarn(){ warn "$1"; WARNINGS+=("$1"); }

have() { command -v "$1" >/dev/null 2>&1; }

# Ensure ~/.bun and ~/.local/bin are visible to this process (bun/claude may
# have just been installed into them).
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"

# ── 1/7 Prerequisites ─────────────────────────────────────────
step "1/7 Prerequisites"
for c in git python3; do
  if have "$c"; then ok "$c found"; else
    fail "$c is required but not installed. Install it and re-run ./install.sh"
  fi
done

if have claude; then
  ok "claude CLI found ($(claude --version 2>/dev/null | head -1))"
else
  fail "claude CLI not on PATH. Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
fi

# bun is required to BUILD gstack's runtime. Install it if missing.
if have bun; then
  ok "bun found ($(bun --version 2>/dev/null))"
else
  softwarn "bun not found — installing bun v$BUN_VERSION (needed to build gstack's browse runtime)"
  tmpfile="$(mktemp)"
  if curl -fsSL "https://bun.sh/install" -o "$tmpfile" 2>/dev/null; then
    if BUN_INSTALL="$HOME/.bun" BUN_VERSION="$BUN_VERSION" bash "$tmpfile" >/dev/null 2>&1; then
      export PATH="$HOME/.bun/bin:$PATH"
      if have bun; then ok "bun installed ($(bun --version 2>/dev/null))"
      else fail "bun installer ran but 'bun' still not on PATH. Add \$HOME/.bun/bin to PATH and re-run."; fi
    else
      fail "bun install failed. Install manually (https://bun.sh) and re-run ./install.sh"
    fi
  else
    fail "could not download bun installer (no network?). Install bun manually and re-run."
  fi
  rm -f "$tmpfile"
fi

# markitdown CLI powers the /markitdown custom skill. Installed via pipx
# (bootstrapped through brew if needed). Non-critical here, but doctor.sh
# treats it as critical while the skill ships in this repo.
if have markitdown; then
  ok "markitdown found ($(command -v markitdown))"
else
  softwarn "markitdown CLI not found — installing via pipx (powers /markitdown)"
  if ! have pipx && have brew; then
    brew install pipx >/dev/null 2>&1 && ok "pipx installed (brew)" || warn "brew install pipx failed"
  fi
  if have pipx; then
    if pipx install 'markitdown[all]' >/dev/null 2>&1 && have markitdown; then
      ok "markitdown installed ($(command -v markitdown))"
    else
      softwarn "markitdown install incomplete — /markitdown won't run. Manual fix: pipx install 'markitdown[all]' && pipx ensurepath"
    fi
  else
    softwarn "pipx unavailable — /markitdown needs its CLI. Manual fix: brew install pipx && pipx install 'markitdown[all]'"
  fi
fi

# ── 2/7 Plugin marketplaces ───────────────────────────────────
step "2/7 Plugin marketplaces"
if have claude; then
  for m in anthropics/claude-plugins-official obra/superpowers-marketplace forrestchang/andrej-karpathy-skills; do
    if claude plugin marketplace add "$m" >/dev/null 2>&1; then ok "marketplace $m"
    else softwarn "marketplace $m (already added or transient error)"; fi
  done
else
  softwarn "skipped (no claude CLI)"
fi

# ── 3/7 Plugins ───────────────────────────────────────────────
step "3/7 Plugins"
# Login-free plugins enabled for everyone. The credential-gated ones
# (firecrawl=API key, supabase=token, vercel=login) are intentionally NOT here —
# they prompt each teammate for personal auth. Enable them yourself if you have
# the credentials: `claude plugin install <name>@claude-plugins-official`.
# playwright is intentionally absent too: /browse (gstack) is our browser stack,
# and settings.shared.json pins playwright off to avoid a third browsing system.
PLUGINS=(
  superpowers@claude-plugins-official
  frontend-design@claude-plugins-official
  swift-lsp@claude-plugins-official
  rust-analyzer-lsp@claude-plugins-official
  claude-md-management@claude-plugins-official
  claude-code-setup@claude-plugins-official
  andrej-karpathy-skills@karpathy-skills
)
if have claude; then
  for p in "${PLUGINS[@]}"; do
    if claude plugin install "$p" >/dev/null 2>&1; then ok "$p"
    else softwarn "$p (already installed or transient error)"; fi
  done
else
  softwarn "skipped (no claude CLI)"
fi

# ── 4/7 gstack: clone + BUILD (the part that was missing) ─────
step "4/7 gstack (clone + build runtime)"
if [ ! -d "$GSTACK_DIR/.git" ]; then
  if git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git "$GSTACK_DIR" 2>&1 | sed 's/^/    /'; then
    ok "gstack cloned"
  else
    fail "gstack clone failed"
  fi
else
  ok "gstack already present"
fi

# Run gstack's own setup — this compiles the browse/design/pdf binaries for THIS
# machine's architecture and registers gstack with Claude Code. Without it the
# skill files exist but nothing runs.
if [ -x "$GSTACK_DIR/setup" ]; then
  if have bun; then
    step "    building gstack (this compiles native binaries; may take a minute)"
    if ( cd "$GSTACK_DIR" && ./setup ) 2>&1 | sed 's/^/    /'; then
      ok "gstack ./setup completed"
    else
      fail "gstack ./setup failed — browse/QA skills will not run. Re-run after fixing the error above."
    fi
  else
    fail "cannot build gstack: bun missing (see step 1)"
  fi
elif [ -d "$GSTACK_DIR" ]; then
  fail "gstack present but ./setup not found — clone may be incomplete. Remove $GSTACK_DIR and re-run."
fi

# ── 5/7 settings.json (deep-merged, non-destructive) ──────────
step "5/7 settings.json (deep-merged, non-destructive)"
SHARED="$REPO/settings.shared.json"
TARGET="$CLAUDE_DIR/settings.json"
if have python3 && [ -f "$SHARED" ]; then
  [ -f "$TARGET" ] && cp "$TARGET" "$TARGET.bak.$(date +%s)" 2>/dev/null || true
  if python3 - "$TARGET" "$SHARED" <<'PY'
import json, sys
target, shared = sys.argv[1], sys.argv[2]
def load(p):
    try:
        with open(p) as f: return json.load(f)
    except FileNotFoundError: return {}
    except Exception as e:
        sys.stderr.write(f"could not parse {p}: {e}\n"); sys.exit(2)
def merge(a, b):
    for k, v in b.items():
        if isinstance(v, dict) and isinstance(a.get(k), dict): merge(a[k], v)
        elif isinstance(v, list) and isinstance(a.get(k), list):
            # Union: keep local entries (personal hooks, extra deny rules),
            # append shared entries that aren't already present.
            a[k] = a[k] + [x for x in v if x not in a[k]]
        else: a[k] = v
    return a
base = merge(load(target), load(shared))
with open(target, "w") as f: json.dump(base, f, indent=2)
PY
  then ok "merged settings.shared.json into $TARGET"
  else fail "settings merge failed (see error above); a .bak was left in place"; fi
else
  fail "skipped settings merge (python3 or settings.shared.json missing)"
fi

# ── 6/7 Shared CLAUDE.md import + skill links ─────────────────
step "6/7 Shared CLAUDE.md import + skill links"
GLOBAL_MD="$CLAUDE_DIR/CLAUDE.md"
IMPORT_LINE="@$REPO/CLAUDE.md"
touch "$GLOBAL_MD"
if grep -qF "$IMPORT_LINE" "$GLOBAL_MD"; then
  ok "shared-practices import already present"
else
  printf '%s\n' "$IMPORT_LINE" | cat - "$GLOBAL_MD" > "$GLOBAL_MD.tmp" && mv "$GLOBAL_MD.tmp" "$GLOBAL_MD" \
    && ok "added shared-practices import to $GLOBAL_MD" \
    || fail "could not write import line to $GLOBAL_MD"
fi

# Mark this as a receiver machine so the SessionStart hook auto-pulls here.
touch "$REPO/.autopull" && ok "auto-pull enabled on this machine (.autopull marker)"

if bash "$REPO/sync.sh"; then ok "custom skills linked (sync.sh)"
else softwarn "sync.sh reported a problem (see above)"; fi

# ── 7/7 Verify end state ──────────────────────────────────────
step "7/7 Verify"
# gstack runtime built?
if [ -x "$GSTACK_DIR/browse/dist/browse" ]; then ok "gstack browse binary present"
else fail "gstack browse binary MISSING ($GSTACK_DIR/browse/dist/browse) — /browse, /qa etc. will not run"; fi
# settings merged?
if [ -f "$TARGET" ] && python3 -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if d.get('hooks',{}).get('SessionStart') else 1)" "$TARGET" 2>/dev/null; then
  ok "SessionStart auto-sync hook installed"
else fail "SessionStart hook not found in settings.json"; fi
# custom skills linked?
linked=0
for d in "$REPO"/skills/*/; do
  n="$(basename "$d")"; case "$n" in _*) continue ;; esac
  [ -e "$CLAUDE_DIR/skills/$n" ] && linked=$((linked+1))
done
ok "$linked custom skill(s) linked into ~/.claude/skills/"

# ── Summary ───────────────────────────────────────────────────
echo
if [ "${#FAILURES[@]}" -eq 0 ]; then
  printf '%s%s✓ Setup complete.%s Restart Claude Code so plugins, settings, and the hook load.\n' "$BOLD" "$GRN" "$RST"
  [ "${#WARNINGS[@]}" -gt 0 ] && printf '%s  (%d non-critical note(s) above — safe to ignore on a re-run.)%s\n' "$DIM" "${#WARNINGS[@]}" "$RST"
  exit 0
else
  printf '%s%s✗ Setup finished with %d problem(s):%s\n' "$BOLD" "$RED" "${#FAILURES[@]}" "$RST"
  for f in "${FAILURES[@]}"; do printf '    %s•%s %s\n' "$RED" "$RST" "$f"; done
  printf '%s  Fix the above and re-run ./install.sh (it is idempotent).%s\n' "$DIM" "$RST"
  exit 1
fi
