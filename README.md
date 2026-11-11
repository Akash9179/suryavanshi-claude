<div align="center">

# 🧩 suryavanshi-claude

**One Claude Code setup, everywhere.**

A shared, version-controlled home for our custom Claude Code skills, working
practices, and configuration — so every machine and every teammate runs the
same setup, and a change made once shows up everywhere.

</div>

---

## ⚡ Fastest way in: let Claude set it up

Open Claude Code on the new machine and paste this prompt. Claude will pull the
repo and run the full setup for you:

```text
Set up my Claude Code environment from the suryavanshi-claude shared repo.

1. Clone https://github.com/Akash9179/suryavanshi-claude.git into ~/suryavanshi-claude
   (if the folder already exists, cd into it and `git pull` instead). The path
   matters: the shared sync hook hardcodes ~/suryavanshi-claude.
2. Run ./install.sh from that folder and show me the output. It is idempotent and
   self-repairing, so it is safe even if some of it has run before. It will
   bootstrap prerequisites (installing bun and the markitdown CLI if missing), install the login-free
   plugins, clone AND BUILD gstack (compiling its browse runtime for this
   machine), deep-merge settings.shared.json into ~/.claude/settings.json, add the
   shared CLAUDE.md import, link custom skills and agents, and install the auto-pull hook.
3. Your goal is a healthy setup: run ./doctor.sh and only report success when it
   exits 0 and prints "👍 GREEN — everything installed and running". If install.sh
   or doctor.sh reports a problem, stop and show it to me — do NOT claim success
   while anything is red.
4. When green, tell me to restart Claude Code so the plugins, settings, and hook load.

Do not commit or push anything, and do not touch my personal memory/, projects/,
or settings.local.json.
```

Prefer to do it by hand? See [**Get set up**](#-get-set-up) below.

---

## 🧩 What is this?

[Claude Code](https://claude.com/claude-code) keeps its configuration in a
`~/.claude/` folder on each machine: your skills, your settings, your working
conventions. The problem: that folder lives on *one* computer. Set something
up on your laptop and your desktop never hears about it. Onboard a teammate and
you're walking them through it by hand.

**This repo fixes that.** It's a single source of truth that:

- 📦 holds our **custom skills** and **agents**
- 📝 holds our **shared working practices** (`CLAUDE.md`)
- ⚙️ holds a **baseline config** (plugins, marketplaces, safety rules)
- 🔄 **auto-syncs** to every machine on each Claude Code launch

Make a change, commit, push — and the next time anyone opens Claude Code, they
have it.

**Why this matters:** it turns our Claude Code setup into shared infrastructure
instead of something each person tinkers with alone. There's no config drift
between machines, onboarding a teammate takes one command instead of an
afternoon, and every improvement someone makes compounds for the whole team —
the setup gets better over time instead of being reinvented on each laptop.

> Inspired by how [gstack](https://github.com/garrytan/gstack) is distributed:
> one git repo of skill folders, kept current with a pull. This is a lighter,
> private version of that idea.

---

## 🔄 How it works

```
 ┌──────────────────────────┐         git push          ┌──────────────────────┐
 │  Your machine            │ ────────────────────────► │  GitHub (private)    │
 │  ~/suryavanshi-claude/   │                           │  suryavanshi-claude  │
 └──────────────────────────┘                           └──────────┬───────────┘
                                                                   │ git pull
                                          on every Claude launch   │ (SessionStart hook)
                                                                   ▼
                                                        ┌──────────────────────┐
                                                        │  Any other machine   │
                                                        │  ~/.claude/skills/ ◄─┼─ symlinks
                                                        └──────────────────────┘
```

A `SessionStart` hook runs [`sync.sh`](./sync.sh) every time Claude Code starts.
That script symlinks each skill folder into `~/.claude/skills/` and each agent
file into `~/.claude/agents/`, and — on
**receiver** machines — pulls the latest from GitHub first, so new skills appear
automatically with no manual step. One caveat: the launch hook silences all of
`sync.sh`'s output, so its warnings (skipped skills, a failed gstack rebuild)
only show when you run `./sync.sh` by hand. `./doctor.sh` reports settings drift.

**Source vs. receiver machines.** Auto-pull is opt-in per machine, gated by a
git-ignored `.autopull` marker that `install.sh` creates. Machines set up with
`install.sh` are *receivers* (they auto-pull). A machine without the marker is a
*source*: it only ever pushes, never auto-pulls, so its setup is never
changed from outside. To pull there, run `git pull` manually — a deliberate act. The marker gates the automatic gstack rebuild too, so after a manual pull on a source machine, rebuild with `cd ~/.claude/skills/gstack && ./setup` if gstack changed. And note `./install.sh` creates `.autopull`: to make (or keep) a machine the source, delete it — `rm ~/suryavanshi-claude/.autopull`.

---

## 📦 What's inside

| Path                   | What it is |
| ---------------------- | ---------- |
| `CLAUDE.md`            | The shared rulebook, imported into each machine's global config: how to work with Akash, writing format, plan-then-execute, model routing (Fable plans, Opus executes, Codex reviews), delivery speed, loop reflexes, web access, one tool per job |
| `skills/`              | Custom skills, one folder each with a `SKILL.md`. `skills/_template/` is the starter (underscore folders are not synced) |
| `agents/`              | Custom agent definitions, one `.md` each. `Explore.md` pins the search agent to Haiku |
| `templates/`           | Fill-in briefs to copy into a project. `codex-browser-qa-brief.md` is a full browser QA brief for Codex |
| `settings.shared.json` | Baseline settings: deny rules, plugins on and off, gstack skills turned off, marketplaces, the sync hook, and the defaults `defaultMode: auto`, `effortLevel: high`, `skipWorkflowUsageWarning: true` |
| `sync.sh`              | Runs on every launch. Links skills and agents, removes links to things deleted from the repo, warns on settings drift. On receiver machines it also pulls and rebuilds gstack when stale |
| `drift-check.py`       | The drift rules. Reports what a machine is missing from the shared settings. Extra personal plugins, marketplaces, allows and hooks are fine |
| `install.sh`           | One-shot setup for a new machine (idempotent, self-repairing). Reads its plugin list from `settings.shared.json` |
| `doctor.sh`            | Health gate. Green only when everything is built and wired |
| `test.sh`              | Tests for `sync.sh` and `drift-check.py`, run in a throwaway home folder. Run it after any change to either |
| `list-skills.sh`       | Regenerates the custom-skills table in this README from `skills/` |

---

## 🧰 What you get

### 1. gstack: browser, QA and design tools

Cloned into `~/.claude/skills/gstack/`. gstack ships about 60 skills. We keep
one tool per job, so `settings.shared.json` turns most of them off. The ones we
use:

| Job | Skill |
| --- | --- |
| Browse and test a running site | `/browse` · `/qa` · `/setup-browser-cookies` |
| Design | `/design-review` · `/design-shotgun` |
| Plan | `/spec` · `/office-hours` |
| Other | `/make-pdf` · `/verify` · `/gstack-upgrade` |

To turn one back on, remove its line from `skillOverrides` in
`settings.shared.json` and in your `~/.claude/settings.json`.

> **Web access** (full rule in [`CLAUDE.md`](./CLAUDE.md)): a running site →
> `/browse`. Scraping and web search → firecrawl. One known URL → WebFetch.
> Never the `claude-in-chrome` tools (denied in shared settings).

### 2. Plugins

`settings.shared.json` is the list. `install.sh` installs what it enables:

| Plugin | What it adds |
| --- | --- |
| **typesafe** | TypeSafe AI building blocks |
| **swift-lsp** | Language server for Swift |

Pinned **off** on purpose, so they do not come back: superpowers, playwright,
frontend-design, claude-md-management, claude-code-setup,
andrej-karpathy-skills, rust-analyzer-lsp.

**Opt-in, per machine.** These need a personal login, so the shared file leaves
them out. Enable with `claude plugin install <name>@<marketplace>`:

| Plugin | What it adds | Needs |
| --- | --- | --- |
| **firecrawl** | Web search, scraping, crawling | API key |
| **codex** (`openai-codex` marketplace) | Independent code review. The rulebook's review step uses it | Codex login |
| **supabase** | Database, auth, edge functions | access token |
| **vercel** | Deployment and env vars | account login |

### 3. Custom skills and agents

Skills live under [`skills/`](./skills/). Run `./list-skills.sh` to regenerate
this table.

<!-- SKILLS:START -->
| Skill | What it does |
| --- | --- |
| `/design-references` | Use when doing any UI or design work — exploring design ideas, brainstorming a look, building or restyling an interface — or when Akash asks for "high quality" or a design review. |
| `/executing-hard-tasks` | Use when starting any multi-step or unfamiliar task, when an instruction conflicts with what the code, comments, or tests say, before reporting any work as done, or when blocked and unsure what to do next. |
| `/markitdown` | Convert any local document or media file to clean Markdown using Microsoft's markitdown. Use when the user hands over a PDF, Word/PowerPoint/Excel file (docx/pptx/xlsx), image, audio file, HTML, CSV/JSON/XML, EPUB, or ZIP and wants its content read, extracted, summarized, or turned into markdown — i.e. "convert this", "read this PDF", "extract the text from", "what's in this file", "turn this doc into markdown". |
| `/memory-hygiene` | Use when auditing, cleaning, or reorganizing Claude Code auto-memory directories, when memories contradict reality or each other, when a project has moved or been renamed, or when MEMORY.md index lines don't match the files on disk. |
| `/starting-projects` | Use when creating a new project or repository from scratch — a new app, service, site, or experiment — before writing any feature code. |
| `/test-driven-development` | Use when implementing any feature or bugfix, before writing implementation code |
<!-- SKILLS:END -->

Agents live under [`agents/`](./agents/). `Explore` replaces the built-in
search agent with one pinned to Haiku, so searches do not run on the session's
model.

> **`/markitdown`'s CLI** is installed by `install.sh` (via pipx, to
> `~/.local/bin`) and checked by `doctor.sh`. Manual fallback: `pipx install 'markitdown[all]'`.

---

## 🚀 Get set up

On a new machine (or for a teammate who's been added to the repo):

```bash
git clone https://github.com/Akash9179/suryavanshi-claude.git ~/suryavanshi-claude
cd ~/suryavanshi-claude && ./install.sh
```

> **The path matters.** The shared SessionStart hook hardcodes
> `~/suryavanshi-claude/sync.sh`. Clone anywhere else and auto-sync is dead.
> `doctor.sh` goes red when the clone is in the wrong place.

`install.sh` is idempotent and self-repairing (safe to re-run). It will:

1. **Bootstrap prerequisites** — check for `git`, `python3`, and the `claude` CLI, and install **bun** (needed to build gstack's runtime) and the **markitdown CLI** (powers `/markitdown`, via pipx) if they're missing
2. Add the marketplaces and install the plugins that `settings.shared.json` enables
3. Clone [gstack](https://github.com/garrytan/gstack) into `~/.claude/skills/` **and run its `./setup`**, which *compiles* the `browse`/`design`/`pdf` binaries for this machine's architecture — without this the gstack skill files exist but nothing runs
4. Deep-merge `settings.shared.json` into your `~/.claude/settings.json` (a timestamped `.bak` is saved first). Lists are unioned, so personal hooks and extra deny rules survive re-runs; the shared team defaults (`defaultMode: auto`, `effortLevel: high`) overwrite those specific keys, and everything else local is untouched
5. Import the shared practices into your global `~/.claude/CLAUDE.md`
6. Link the custom skills and agents and install the auto-pull hook
7. **Verify** the end state and only report success when every critical piece is in place — otherwise list exactly what failed and exit non-zero

### Is it actually working? Run the doctor

```bash
cd ~/suryavanshi-claude && ./doctor.sh
```

`doctor.sh` is the **definitive check** for a healthy setup. It checks the
*real runtime* — not just that files exist — so it catches the classic failure
where gstack's files are present but its `browse` binary was never compiled. (Plugin checks are settings-level only — if a plugin's
skills are missing after a green run, re-run `./install.sh` and watch its plugin
step.) It
prints `👍 GREEN — everything installed and running` and exits `0` only when every
critical check passes; otherwise it prints `👎 RED` and exits `1`. Use it as the goal you
hand an agent: *"set this up and don't tell me it's done until `./doctor.sh` is green."*

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

**A note on MCP servers & personal logins:** the shared repo enables only
**login-free** plugins by default. The ones that need a personal credential —
**firecrawl** (API key), **codex** (login), **supabase** (token), and **vercel** (login) — are
intentionally left **off** so no teammate is forced to authenticate to get set
up. Enable them yourself if you use them (see the opt-in table above); your
credentials live only on your machine and are never committed. Personal
claude.ai connectors (Gmail, Google Drive, Calendar) are tied to your account
and are not part of this repo at all.

---

## 🛠 Troubleshooting

| Symptom | Fix |
| --- | --- |
| Anything seems off / want a health check | Run `./doctor.sh` — it tells you exactly what's red and how to fix it |
| gstack skills present but `/browse`, `/qa`, etc. don't run | gstack's runtime wasn't compiled. Run `cd ~/.claude/skills/gstack && ./setup` (needs `bun`), or just re-run `./install.sh` |
| `bun: command not found` during install | `install.sh` installs bun to `~/.bun`; open a new shell (or `export PATH="$HOME/.bun/bin:$PATH"`) and re-run |
| A new skill didn't appear | Restart Claude Code, or run `./sync.sh` manually |
| `sync: skipping '<name>'` warning | A non-symlink with that name already exists in `~/.claude/skills/` (often a gstack skill). Rename your skill to avoid the clash |
| `/markitdown` fails | Re-run `./install.sh` (installs its CLI via pipx), or: `pipx install 'markitdown[all]'` |
| Plugins missing after clone | Re-run `./install.sh`, then restart Claude Code |
| Want firecrawl/codex/supabase/vercel | They're opt-in: `claude plugin install <name>@<marketplace>`, then add your credential |
| A deleted skill still shows up | Run `./sync.sh`. It removes links to things that left the repo |
| `doctor.sh` notes settings drift | This machine is missing a shared setting. Re-run `./install.sh`, or fix the named key by hand |
| Changed `sync.sh` or `drift-check.py` | Run `./test.sh` before you push |

---

<div align="center">
<sub>Private toolkit · maintained by Akash Suryavanshi</sub>
</div>
