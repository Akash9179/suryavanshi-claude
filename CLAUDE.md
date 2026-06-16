# Shared practices (suryavanshi-claude)

These are general working conventions, imported into each machine's global
CLAUDE.md. No personal memory or project context lives here.

# Dynamic workflows
- Proactively **recommend** dynamic multi-agent Workflows (the `Workflow` tool) wherever a task genuinely fits — wide/multi-file work, tasks needing independent verification, or unknown-size discovery. Surface a one-line shape with the offer.
- **The user always makes the decision to run one.** Never launch a Workflow without explicit go-ahead. Say so plainly when a workflow would be overkill (single-file/one-off/trivial).

# gstack
- **gstack** (`~/.claude/skills/gstack/`) - planning, review, ship/deploy, browser QA, and team workflow skills.
- For ALL web browsing, use the `/browse` skill from gstack. NEVER use `mcp__claude-in-chrome__*` tools.
- Available skills: `/office-hours`, `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/design-consultation`, `/design-shotgun`, `/design-html`, `/review`, `/ship`, `/land-and-deploy`, `/canary`, `/benchmark`, `/browse`, `/connect-chrome`, `/qa`, `/qa-only`, `/design-review`, `/setup-browser-cookies`, `/setup-deploy`, `/setup-gbrain`, `/retro`, `/investigate`, `/document-release`, `/codex`, `/cso`, `/autoplan`, `/plan-devex-review`, `/devex-review`, `/careful`, `/freeze`, `/guard`, `/unfreeze`, `/gstack-upgrade`, `/learn`.

# Design references (applies to ALL projects)
- For ANY UI/design work — exploring design ideas, brainstorming a look, building or restyling an interface — consult the curated **awesome-design-md** collection first: https://github.com/voltagent/awesome-design-md (real, analyzed DESIGN.md files for Apple, Airbnb, Linear, Stripe, Vercel, Notion, Figma, Spotify, Nike, and ~80 more). Pull the relevant brand's spec raw and ground tokens/type/spacing/aesthetic in it before proposing or building: `https://raw.githubusercontent.com/voltagent/awesome-design-md/main/design-md/<name>/DESIGN.md` (list folder names via the GitHub contents API for `design-md/`).
- When I say I want **high quality** or ask for a **design review**, treat that as a hard bar: pick the closest reference(s) from that repo, extract their concrete tokens, and match that level — do not ship generic/AI-default UI.
- **Default taste target:** modern, luxurious, simple — Apple/Airbnb-grade. Light canvas, generous whitespace, ONE restrained accent, clean geometric sans, photography-first. Avoid dark-editorial-by-default unless I ask for it.

# Custom skills
- Custom skills live in this repo under `skills/` and are symlinked into `~/.claude/skills/`. Run `~/suryavanshi-claude/sync.sh` after adding one.
