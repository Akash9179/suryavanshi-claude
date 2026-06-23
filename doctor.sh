#!/usr/bin/env bash
# doctor.sh — the "is everything actually installed AND running?" gate.
#
# This is the single source of truth for a healthy suryavanshi-claude setup.
# It checks every required artifact (not just that files exist, but that the
# runtime is built and wired) and prints a green thumbs-up ONLY when all
# critical checks pass. Exit 0 = healthy, exit 1 = something is broken.
#
# Use it as the goal for an agent: "run ./doctor.sh and only report success
# when it exits 0 with a 👍". Re-run ./install.sh to fix anything red.
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
GSTACK_DIR="$CLAUDE_DIR/skills/gstack"
SETTINGS="$CLAUDE_DIR/settings.json"
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"

if [ -t 1 ]; then BOLD=$'\033[1m'; RED=$'\033[31m'; GRN=$'\033[32m'; YEL=$'\033[33m'; RST=$'\033[0m'
else BOLD=''; RED=''; GRN=''; YEL=''; RST=''; fi

CRIT_FAIL=0
WARN=0
pass() { printf '  %s✓%s %s\n' "$GRN" "$RST" "$*"; }
crit() { printf '  %s✗%s %s\n' "$RED" "$RST" "$*"; CRIT_FAIL=$((CRIT_FAIL+1)); }
note() { printf '  %s!%s %s\n' "$YEL" "$RST" "$*"; WARN=$((WARN+1)); }
have() { command -v "$1" >/dev/null 2>&1; }

printf '%ssuryavanshi-claude doctor%s\n\n' "$BOLD" "$RST"

# ── Prerequisites ─────────────────────────────────────────────
printf '%sPrerequisites%s\n' "$BOLD" "$RST"
for c in git python3 claude bun; do
  if have "$c"; then pass "$c ($(command -v "$c"))"; else crit "$c not on PATH"; fi
done

# ── gstack runtime ────────────────────────────────────────────
printf '\n%sgstack runtime%s\n' "$BOLD" "$RST"
if [ -d "$GSTACK_DIR/.git" ]; then pass "gstack cloned"; else crit "gstack not cloned at $GSTACK_DIR"; fi
if [ -x "$GSTACK_DIR/browse/dist/browse" ]; then
  pass "browse binary built ($("$GSTACK_DIR/browse/dist/browse" --version 2>/dev/null | head -1 || echo present))"
else
  crit "browse binary missing/not built — /browse, /qa, /design-review will not run"
fi

# ── settings.json wiring ──────────────────────────────────────
printf '\n%sConfig wiring%s\n' "$BOLD" "$RST"
if [ -f "$SETTINGS" ] && have python3; then
  python3 - "$SETTINGS" <<'PY'
import json, sys
try: d = json.load(open(sys.argv[1]))
except Exception as e: print("PARSE_FAIL", e); sys.exit(0)
hook = bool(d.get("hooks", {}).get("SessionStart"))
n_plugins = sum(1 for v in (d.get("enabledPlugins") or {}).values() if v)
print("HOOK", "yes" if hook else "no")
print("PLUGINS", n_plugins)
PY
else
  echo "PARSE_FAIL no settings.json"
fi > /tmp/.sc_doctor_settings.$$ 2>/dev/null
while read -r key val rest; do
  case "$key" in
    HOOK)    [ "$val" = "yes" ] && pass "SessionStart auto-sync hook installed" || crit "SessionStart hook missing from settings.json" ;;
    PLUGINS) [ "${val:-0}" -gt 0 ] 2>/dev/null && pass "$val plugin(s) enabled in settings.json" || note "no plugins enabled in settings.json" ;;
    PARSE_FAIL) crit "settings.json missing or unreadable ($val $rest)" ;;
  esac
done < /tmp/.sc_doctor_settings.$$
rm -f /tmp/.sc_doctor_settings.$$

GLOBAL_MD="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$GLOBAL_MD" ] && grep -qF "@$REPO/CLAUDE.md" "$GLOBAL_MD"; then
  pass "shared CLAUDE.md import present"
else
  crit "shared CLAUDE.md import missing from $GLOBAL_MD"
fi

# ── Custom skills ─────────────────────────────────────────────
printf '\n%sCustom skills%s\n' "$BOLD" "$RST"
linked=0; missing=0
for d in "$REPO"/skills/*/; do
  [ -d "$d" ] || continue
  n="$(basename "$d")"; case "$n" in _*) continue ;; esac
  if [ -e "$CLAUDE_DIR/skills/$n" ]; then pass "$n linked"; linked=$((linked+1))
  else note "$n NOT linked"; missing=$((missing+1)); fi
done
[ "$linked" -eq 0 ] && [ "$missing" -eq 0 ] && note "no custom skills in repo yet"

# ── Verdict ───────────────────────────────────────────────────
echo
if [ "$CRIT_FAIL" -eq 0 ]; then
  printf '%s%s👍 GREEN — everything installed and running.%s' "$BOLD" "$GRN" "$RST"
  [ "$WARN" -gt 0 ] && printf ' %s(%d note(s))%s' "$YEL" "$WARN" "$RST"
  echo
  exit 0
else
  printf '%s%s👎 RED — %d critical problem(s). Run ./install.sh to fix.%s\n' "$BOLD" "$RED" "$CRIT_FAIL" "$RST"
  exit 1
fi
