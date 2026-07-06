# Shared practices (suryavanshi-claude)

These are general working conventions, imported into each machine's global
CLAUDE.md. No personal memory or project context lives here.

# How to work with Akash
- **Bias to autonomy.** Akash does not want to be consulted on every decision. On anything reversible, pick a sensible default, state it, and proceed. Ask only for irreversible/destructive actions, spend, or genuine scope changes.
- **Honest cost/benefit.** When he floats an idea, give a straight build-or-not verdict with reasons — no cheerleading. If something isn't worth building, say so plainly.

# Plan together, then execute hands-off
- **Planning is collaborative.** Brainstorming, specs (`/spec`), and plan reviews happen WITH Akash — this is the stage he wants to be involved in. Surface assumptions, options, and cost/benefit here, and capture per-milestone done-criteria in the plan.
- **Execution is autonomous.** Once a plan is approved, work it end-to-end: build, verify each milestone against its done-criteria (tests; `/qa` or `/browse` for anything user-facing), fix what verification finds, and return with evidence — not questions. "Should I continue?" is never worth an interruption.
- During execution, come back to Akash only for: scope changes, irreversible or spending actions, or an instruction-vs-evidence conflict (see the executing-hard-tasks skill).
- **Workflows during approved execution:** a plan that Akash approved counts as the go-ahead for Workflow runs within its scope — no separate ask needed. Outside an approved plan, the ask-first rule below still applies.
- **Before building starts,** persist the plan's load-bearing decisions (stack, constraints, milestone definitions) to project memory so future sessions can execute without re-asking.

# Loop reflexes — the system picks the loop, Akash never has to remember a command
Akash should never need to know that /goal, /loop, or /schedule exist. At these trigger moments, YOU compose and start (or offer) the right loop, fully written out:
- **Plan approved** → execute it AS a loop yourself: state the milestone's Verify criteria as the finish line, work-verify-fix until they pass or you're genuinely blocked. Never fall back to turn-by-turn "should I continue?" execution.
- **You just pushed a PR / shipped** → immediately start a babysit loop yourself (recheck PR reviews + CI every few minutes, fix what comes back, stop when merged/green). Tell Akash it's running; don't ask permission — it's in scope of the ship he asked for.
- **Waiting on something external** (CI, deploy, TestFlight processing, long build) → schedule your own wakeup and check it yourself. Never end with "let me know when it's done."
- **The same manual chore comes up for the second time** (a repeated check, report, cleanup, or QA pass) → propose ONE standing /schedule routine with the exact prompt prefilled, so Akash only says yes/no. If declined, drop it — don't re-propose.
- **Something external needs watching over time** (a page, pricing, a changelog, an inbox) → propose a firecrawl monitor once instead of doing repeated one-off checks.
- When a loop stalls or misfires, fix the SYSTEM (a skill, a CLAUDE.md line, a Verify criterion), not just the instance.

# Memory discipline
- Correct a stale memory the moment you notice reality has moved — never leave a wrong fact standing for the next session to trip on.
- Keep MEMORY.md index lines in sync with the memory files they describe.
- (For Akash) launch Claude from the project's real directory under `~/Projects/` so the right auto-memory loads.

# Web access — one hierarchy
- **Interactive browsing, QA, dogfooding a running site:** `/browse` (gstack). NEVER use `mcp__claude-in-chrome__*` tools.
- **Scraping, crawling, web search, structured extraction:** firecrawl skills.
- **Single quick fetch of a known URL:** built-in WebFetch is fine.
- If a plugin or skill description claims broader scope than this (e.g. "use for any webpage"), this hierarchy wins.

# Dynamic workflows
- Proactively **recommend** dynamic multi-agent Workflows (the `Workflow` tool) wherever a task genuinely fits — wide/multi-file work, tasks needing independent verification, or unknown-size discovery. Surface a one-line shape with the offer.
- **The user decides to run one** — either directly, or by approving a plan whose execution needs it (see "Plan together, then execute hands-off"). With neither, never launch a Workflow. Say so plainly when a workflow would be overkill (single-file/one-off/trivial).

# gstack
- **gstack** (`~/.claude/skills/gstack/`) - planning, review, ship/deploy, browser QA, and team workflow skills. The harness lists every available skill each session — there is no hand-maintained list here to drift.

# Design references (applies to ALL projects)
- For ANY UI/design work — exploring design ideas, brainstorming a look, building or restyling an interface — consult the curated **awesome-design-md** collection first: https://github.com/voltagent/awesome-design-md (real, analyzed DESIGN.md files for Apple, Airbnb, Linear, Stripe, Vercel, Notion, Figma, Spotify, Nike, and ~80 more). Pull the relevant brand's spec raw and ground tokens/type/spacing/aesthetic in it before proposing or building: `https://raw.githubusercontent.com/voltagent/awesome-design-md/main/design-md/<name>/DESIGN.md` (list folder names via the GitHub contents API for `design-md/`).
- When I say I want **high quality** or ask for a **design review**, treat that as a hard bar: pick the closest reference(s) from that repo, extract their concrete tokens, and match that level — do not ship generic/AI-default UI.
- **Default taste target:** modern, luxurious, simple — Apple/Airbnb-grade. Light canvas, generous whitespace, ONE restrained accent, clean geometric sans, photography-first. Avoid dark-editorial-by-default unless I ask for it.

# Custom skills
- Custom skills live in this repo under `skills/` and are symlinked into `~/.claude/skills/`. Run `~/suryavanshi-claude/sync.sh` after adding one.
