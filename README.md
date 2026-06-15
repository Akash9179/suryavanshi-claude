<div align="center">

# 🧩 suryavanshi-claude

**One Claude Code setup, everywhere.**

A shared, version-controlled home for our custom Claude Code skills, working
practices, and configuration — so every machine and every teammate runs the
same setup, and a change made once shows up everywhere.

</div>

---

## What is this?

[Claude Code](https://claude.com/claude-code) keeps its configuration in a
`~/.claude/` folder on each machine: your skills, your settings, your working
conventions. The problem is that folder lives on *one* computer. Set something
up on your laptop and your desktop never hears about it. Onboard a teammate and
you're walking them through it by hand.

**This repo fixes that.** It's a single source of truth that:

- 📦 holds our **custom skills** (one folder each)
- 📝 holds our **shared working practices** (`CLAUDE.md`)
- ⚙️ holds a **baseline config** (plugins, marketplaces, safety rules)
- 🔄 **auto-syncs** to every machine on each Claude Code launch

Make a change, commit, push — and the next time anyone opens Claude Code, they
have it.

> Inspired by how [gstack](https://github.com/garrytan/gstack) is distributed:
> one git repo of skill folders, kept current with a pull. This is a lighter,
> private version of that idea.

---

## How it works

```
 ┌─────────────────────────┐         git push          ┌──────────────────────┐
 │  Your machine            │  ───────────────────────► │  GitHub (private)    │
 │  ~/suryavanshi-claude/   │                           │  suryavanshi-claude  │
 └─────────────────────────┘                           └──────────┬───────────┘
                                                                   │ git pull
                                          on every Claude launch   │ (SessionStart hook)
                                                                   ▼
                                                        ┌──────────────────────┐
                                                        │  Any other machine   │
                                                        │  ~/.claude/skills/ ◄─┼─ symlinks
                                                        └──────────────────────┘
```

A `SessionStart` hook runs [`sync.sh`](./sync.sh) every time Claude Code starts.
That script pulls the latest from GitHub and symlinks each skill folder into
`~/.claude/skills/`, so new skills appear automatically — no manual step on the
receiving machine.

---

## What's inside

| Path                     | What it is                                                        |
| ------------------------ | ----------------------------------------------------------------- |
| `skills/`                | Custom skills — one folder per skill, each with a `SKILL.md`      |
| `skills/_template/`      | Copy this to start a new skill (underscore folders aren't synced) |
| `CLAUDE.md`              | Shared working practices, imported into each machine's global config |
| `settings.shared.json`   | Baseline settings: plugins, marketplaces, safety rules, sync hook |
| `sync.sh`                | Pulls latest + links skills into `~/.claude/skills/`              |
| `install.sh`             | One-shot setup for a new machine or teammate                       |

---

## 🧰 What you get

Setting up this repo gives every machine the same toolbox. It comes from three
places:

### 1. gstack — planning, review, ship & browser QA

Cloned into `~/.claude/skills/gstack/`. A large suite of workflow skills:

| Area | Skills |
| --- | --- |
| **Plan & review** | `/plan-ceo-review` · `/plan-eng-review` · `/plan-design-review` · `/plan-devex-review` · `/review` · `/autoplan` · `/spec` |
| **Ship & deploy** | `/ship` · `/land-and-deploy` · `/canary` · `/setup-deploy` |
| **Design** | `/design-consultation` · `/design-shotgun` · `/design-html` · `/design-review` |
| **QA & browser** | `/browse` · `/qa` · `/qa-only` · `/connect-chrome` · `/setup-browser-cookies` |
| **iOS** | `/ios-qa` · `/ios-fix` · `/ios-design-review` · `/ios-sync` · `/ios-clean` |
| **Ops & misc** | `/investigate` · `/cso` · `/benchmark` · `/retro` · `/document-release` · `/codex` · `/freeze` · `/guard` · `/learn` · `/gstack-upgrade` |

> For **all** web browsing, use `/browse` from gstack.

### 2. Plugins — from the official & community marketplaces

Installed automatically by `install.sh`:

| Plugin | What it adds |
| --- | --- |
| **superpowers** | Core engineering workflow: brainstorming, TDD, systematic debugging, writing & executing plans, code review, git worktrees |
| **vercel** | Deploying, Next.js, AI SDK, storage, env vars, CLI, and more |
| **supabase** | Database, auth, edge functions, migrations, RLS |
| **playwright** | Browser automation & testing |
| **frontend-design** | Distinctive, production-grade UI generation |
| **firecrawl** | Web search, scraping, crawling, structured extraction |
| **claude-md-management** | Audit & improve `CLAUDE.md` files |
| **claude-code-setup** | Recommend hooks, subagents, skills, MCP servers |
| **andrej-karpathy-skills** | Guidelines to reduce common LLM coding mistakes |
| **swift-lsp** / **rust-analyzer-lsp** | Language servers for Swift & Rust |

### 3. Custom skills — ours, in this repo

Anything we add under [`skills/`](./skills/). Currently a starter `_template`
to copy from. As we build skills, they're listed here automatically once linked.

> **Not included:** personal/project-specific tools (e.g. local-only skills like
> graphify) and project context (Nitecapp, etc.) are deliberately kept out — see
> [What stays private](#-what-stays-private).

---

## 🚀 Get set up

On a new machine (or for a teammate who's been added to the repo):

```bash
git clone https://github.com/Akash9179/suryavanshi-claude.git ~/suryavanshi-claude
cd ~/suryavanshi-claude && ./install.sh
```

`install.sh` is idempotent (safe to re-run) and will:

1. Add the plugin marketplaces and install our plugins
2. Clone [gstack](https://github.com/garrytan/gstack) into `~/.claude/skills/`
3. Deep-merge `settings.shared.json` into your `~/.claude/settings.json` (backing up the original first — your local settings are preserved)
4. Import the shared practices into your global `~/.claude/CLAUDE.md`
5. Link the custom skills and install the auto-pull hook

Then **restart Claude Code** so everything loads.

---

## ✍️ Add a new skill

```bash
# 1. Start from the template
cp -r ~/suryavanshi-claude/skills/_template ~/suryavanshi-claude/skills/my-skill

# 2. Edit skills/my-skill/SKILL.md  (set name + description in the frontmatter)

# 3. Link it locally
cd ~/suryavanshi-claude && ./sync.sh

# 4. Share it
git add skills/my-skill && git commit -m "Add my-skill" && git push
```

Every other machine picks it up on its next Claude Code launch. The skill
becomes available as `/my-skill`.

---

## 🔒 What stays private

This repo is for **general, shareable** setup only. The following are never
committed — they're excluded in [`.gitignore`](./.gitignore):

- `memory/` and `projects/` — personal memory and project context
- `settings.local.json` — per-machine permission allowlists
- `.env`, API keys, secrets

**A note on MCP servers:** plugins like Supabase, Firecrawl, Playwright, and
Vercel sync via this repo, but their credentials do **not**. Each machine
re-authenticates those on first use — by design, since they're secrets.

---

## 🛠 Troubleshooting

| Symptom | Fix |
| --- | --- |
| A new skill didn't appear | Restart Claude Code, or run `./sync.sh` manually |
| `sync: skipping '<name>'` warning | A non-symlink with that name already exists in `~/.claude/skills/` (often a gstack skill). Rename your skill to avoid the clash. |
| Plugins missing after clone | Re-run `./install.sh`, then restart Claude Code |
| An MCP server isn't working | Re-authenticate it / add its API key on this machine |

---

<div align="center">
<sub>Private toolkit · maintained by Akash Suryavanshi</sub>
</div>
