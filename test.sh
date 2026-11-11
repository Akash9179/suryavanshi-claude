#!/usr/bin/env bash
# Tests for sync.sh and drift-check.py. Runs in a throwaway HOME and a throwaway
# copy of the repo scripts, so it never touches the real ~/.claude.
# Usage: ./test.sh   (exit 0 = all pass)
set -u

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf '  ✓ %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  ✗ %s\n' "$1"; }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }

# Build a sandbox: fake HOME and a fake repo holding the real scripts.
new_sandbox() {
  BOX="$(mktemp -d)"
  export HOME="$BOX/home"
  REPO="$BOX/repo"
  mkdir -p "$HOME/.claude" "$REPO/skills/alpha" "$REPO/skills/_template" "$REPO/agents"
  cp "$SRC/sync.sh" "$SRC/drift-check.py" "$REPO/" 2>/dev/null
  echo "alpha" > "$REPO/skills/alpha/SKILL.md"
  echo "tmpl"  > "$REPO/skills/_template/SKILL.md"
  echo "agent" > "$REPO/agents/Scout.md"
}
REAL_HOME="$HOME"
trap 'export HOME="$REAL_HOME"' EXIT

echo "sync.sh: linking"
new_sandbox
bash "$REPO/sync.sh" >/dev/null 2>&1
check "links a skill folder"             '[ -L "$HOME/.claude/skills/alpha" ] && [ -f "$HOME/.claude/skills/alpha/SKILL.md" ]'
check "skips underscore folders"         '[ ! -e "$HOME/.claude/skills/_template" ]'
check "links an agent file"              '[ -L "$HOME/.claude/agents/Scout.md" ] && [ -f "$HOME/.claude/agents/Scout.md" ]'

echo "sync.sh: leaves what it does not own"
new_sandbox
mkdir -p "$HOME/.claude/skills/alpha" && echo "mine" > "$HOME/.claude/skills/alpha/SKILL.md"
out="$(bash "$REPO/sync.sh" 2>&1)"
check "keeps a real folder with the same name" '[ ! -L "$HOME/.claude/skills/alpha" ] && grep -q mine "$HOME/.claude/skills/alpha/SKILL.md"'
check "warns about the name clash"            'printf "%s" "$out" | grep -q "skipping .alpha."'

echo "sync.sh: pruning"
new_sandbox
bash "$REPO/sync.sh" >/dev/null 2>&1
rm -rf "$REPO/skills/alpha" "$REPO/agents/Scout.md"
ln -s "$BOX/nowhere" "$HOME/.claude/skills/foreign"      # dangling, but not ours
bash "$REPO/sync.sh" >/dev/null 2>&1
check "removes the link of a deleted skill"  '[ ! -L "$HOME/.claude/skills/alpha" ]'
check "removes the link of a deleted agent"  '[ ! -L "$HOME/.claude/agents/Scout.md" ]'
check "keeps a dangling link it does not own" '[ -L "$HOME/.claude/skills/foreign" ]'

echo "drift-check.py"
new_sandbox
D="$REPO/drift-check.py"
shared="$BOX/shared.json"; live="$BOX/live.json"
cat > "$shared" <<'JSON'
{"permissions":{"deny":["Bash(rm -rf *)"],"defaultMode":"auto"},
 "enabledPlugins":{"a@m":true,"b@m":false},
 "skillOverrides":{"ship":"off"},
 "extraKnownMarketplaces":{"m":{"source":{"source":"github","repo":"x/m"}}},
 "effortLevel":"high",
 "hooks":{"SessionStart":[{"matcher":"startup","hooks":[{"type":"command","command":"sync"}]}]}}
JSON
# A healthy machine: everything shared is present, plus personal extras.
cat > "$live" <<'JSON'
{"permissions":{"deny":["Bash(rm -rf *)"],"defaultMode":"auto","allow":["Bash(gh pr merge:*)"]},
 "enabledPlugins":{"a@m":true,"b@m":false,"extra@other":true},
 "skillOverrides":{"ship":"off"},
 "extraKnownMarketplaces":{"m":{"source":{"source":"github","repo":"x/m"}},"other":{"source":{"source":"github","repo":"y/o"}}},
 "effortLevel":"high","model":"fable",
 "hooks":{"SessionStart":[{"matcher":"startup","hooks":[{"type":"command","command":"sync"}]},{"hooks":[{"type":"command","command":"personal"}]}]}}
JSON
out="$(python3 "$D" "$shared" "$live" 2>&1)"; rc=$?
check "personal extras are not drift (exit 0, no output)" '[ "$rc" -eq 0 ] && [ -z "$out" ]'

python3 - "$live" <<'PY'
import json,sys
d=json.load(open(sys.argv[1])); del d["extraKnownMarketplaces"]["m"]; d["permissions"]["deny"]=[]
d["enabledPlugins"]["b@m"]=True; d["hooks"]["SessionStart"]=[]; d["skillOverrides"]={}
json.dump(d,open(sys.argv[1],"w"))
PY
out="$(python3 "$D" "$shared" "$live" 2>&1)"; rc=$?
check "exits 1 when shared settings are missing"  '[ "$rc" -eq 1 ]'
check "names a missing marketplace"   'printf "%s" "$out" | grep -q "extraKnownMarketplaces.m"'
check "names a changed deny list"     'printf "%s" "$out" | grep -q "permissions.deny"'
check "names a flipped plugin"        'printf "%s" "$out" | grep -q "enabledPlugins.b@m"'
check "names a missing skill override" 'printf "%s" "$out" | grep -q "skillOverrides.ship"'
check "names a missing hook"          'printf "%s" "$out" | grep -q "hooks.SessionStart"'

echo
if [ "$FAIL" -eq 0 ]; then echo "PASS — $PASS checks"; exit 0
else echo "FAIL — $FAIL of $((PASS+FAIL)) checks failed"; exit 1; fi
