#!/usr/bin/env bash
# Regenerate the custom-skills list in README.md from the skills/ folder.
# Reads each skills/<name>/SKILL.md frontmatter and writes a table between the
# <!-- SKILLS:START --> and <!-- SKILLS:END --> markers in README.md.
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="$REPO/skills"
README="$REPO/README.md"

# Pull a single frontmatter value (first occurrence inside the top --- block).
frontmatter() {
  sed -n '/^---$/,/^---$/p' "$1" | grep -m1 "^$2:" | sed "s/^$2:[[:space:]]*//"
}

rows=""
count=0
for dir in "$SKILLS"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  case "$name" in _*) continue ;; esac          # skip _template etc.
  md="$dir/SKILL.md"
  [ -f "$md" ] || continue
  desc="$(frontmatter "$md" description)"
  [ -n "$desc" ] || desc="(no description)"
  rows+="| \`/$name\` | $desc |"$'\n'
  count=$((count + 1))
done

# Build the replacement block.
block="$(mktemp)"
if [ "$count" -gt 0 ]; then
  {
    printf '| Skill | What it does |\n'
    printf '| --- | --- |\n'
    printf '%s' "$rows"
  } > "$block"
else
  printf '_No custom skills yet — copy `skills/_template/` to create one._\n' > "$block"
fi

# Splice it between the markers in README.md.
if ! grep -q '<!-- SKILLS:START -->' "$README"; then
  echo "list-skills: markers not found in README.md — nothing to update." >&2
  echo "Add these two lines where the list should go:" >&2
  echo "  <!-- SKILLS:START -->" >&2
  echo "  <!-- SKILLS:END -->" >&2
  cat "$block"; rm -f "$block"; exit 1
fi

awk -v f="$block" '
  /<!-- SKILLS:START -->/ { print; while ((getline line < f) > 0) print line; skip=1; next }
  /<!-- SKILLS:END -->/   { skip=0 }
  !skip                   { print }
' "$README" > "$README.tmp" && mv "$README.tmp" "$README"
rm -f "$block"

echo "list-skills: updated README.md with $count custom skill(s)."
