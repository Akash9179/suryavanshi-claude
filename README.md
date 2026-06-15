# suryavanshi-claude

Shared Claude Code skills, practices, and config — synced across my machines and
shareable with the team. Modeled on how gstack is distributed: one git repo of
skill folders plus shared config, kept current with a git pull on every session
start.

**This repo is general-purpose only.** It deliberately contains no personal
memory, no project context, and no per-machine secrets.

## What's in here

| Path                  | What it is                                              |
| --------------------- | ------------------------------------------------------- |
| `skills/`             | Custom skills. One folder per skill, each with SKILL.md |
| `CLAUDE.md`           | Shared working practices, imported into each machine    |
| `settings.shared.json`| Baseline Claude Code settings (plugins, marketplaces)   |
| `sync.sh`             | Pulls latest + symlinks skills into `~/.claude/skills/` |
| `install.sh`          | First-time setup on a new machine / for a teammate      |

## Set up on a new machine / for a teammate

```bash
git clone git@github.com:<owner>/suryavanshi-claude.git ~/suryavanshi-claude
cd ~/suryavanshi-claude && ./install.sh
```

`install.sh` installs the plugins, symlinks the skills, wires up the shared
CLAUDE.md, and adds a SessionStart hook so the repo auto-pulls on every launch.

## Add a new skill

```bash
cp -r ~/suryavanshi-claude/skills/_template ~/suryavanshi-claude/skills/my-skill
# edit skills/my-skill/SKILL.md
cd ~/suryavanshi-claude && ./sync.sh        # links it locally
git add skills/my-skill && git commit -m "Add my-skill" && git push
```

Other machines pick it up automatically on their next Claude Code launch.

## What stays private (never committed)

`memory/`, `projects/`, `settings.local.json`, sessions, history, and caches.
See `.gitignore`.
