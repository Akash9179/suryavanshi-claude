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

# Custom skills
- Custom skills live in this repo under `skills/` and are symlinked into `~/.claude/skills/`. Run `~/suryavanshi-claude/sync.sh` after adding one.
