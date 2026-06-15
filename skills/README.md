# skills/

One folder per custom skill. Each folder needs a `SKILL.md` with YAML
frontmatter (`name`, `description`). `sync.sh` symlinks every folder here into
`~/.claude/skills/`, so the skill becomes available as `/<name>`.

- Folders starting with `_` are ignored by sync (e.g. `_template`).
- Copy `_template/` to start a new skill.
