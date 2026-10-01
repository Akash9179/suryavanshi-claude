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
- **Workflows during approved execution:** a plan that Akash approved counts as the go-ahead for Workflow runs within its scope — no separate ask needed. Outside an approved plan, offer the Workflow and wait for a yes (see Dynamic workflows).
- **Before building starts,** persist the plan's load-bearing decisions (stack, constraints, milestone definitions) to project memory so future sessions can execute without re-asking.

# Claude + Codex engineering collaboration
- **Roles.** Claude Code is the tech lead, context owner, and primary implementer. Codex, available through MCP, is an independent principal engineer, debugger, and adversarial reviewer.
- **Model routing.** Three roles, three models. Do not increase model cost or latency beyond this without a material expected benefit:
  - **Fable 5.1 — planning and reviewing.** The main session (this cannot be switched by code; Akash sets it with `/model`). All specs, plans, design decisions, reading Codex findings, final-diff judgment, and anything that changes an interface stay here.
  - **Opus 5.5 — execution.** Every Agent or Workflow agent that writes code, tests, migrations or docs passes `model: "opus"` explicitly. Cheaper models (`model: "sonnet"` or `"haiku"`) only for pure search/grep/summarise steps.
  - **Codex Astra (`gpt-6-astra`) — independent review.** Every Codex call passes `model: "gpt-6-astra"` explicitly (also the default in `~/.codex/config.toml`). Used for the review checkpoints and independent diagnosis when a patch loop is stopped; never for execution.
  - At the end of any session that spawned agents or called Codex, report `/cost` and one line on where tokens went.
- **Investigate independently first.** Before consulting Codex, understand the requirement, inspect the relevant repository evidence, identify the likely implementation boundary, and form an independent technical opinion. Ask Codex to investigate or falsify assumptions, not merely to validate Claude's conclusion.
- **Use Codex selectively.** Consult Codex when independent reasoning materially improves correctness, security, architecture, debugging, or reliability. Do not invoke it for trivial text, styling, formatting, renaming, documentation, or obvious one-line changes.
- **High-risk review.** Independent Codex analysis and final-diff review are normally required for authentication, authorization, permissions, RLS, tenant isolation, payments, database migrations, destructive data operations, infrastructure, deployment configuration, secrets, cryptography, concurrency, major refactors, and production data-integrity logic.
- **Stripe go-live gate.** Before flipping Stripe to live mode in any project, run the 20-item checklist unprompted (webhook signature verification, failed payments, refunds, upgrades/downgrades, idempotency keys, server-side feature gating, subscription-status sync to DB, test clocks, billing portal, receipts, payment-event logging, expired cards, tax, trial rules, duplicate-charge prevention, multi-currency, working cancel flow, dunning retries, failed-webhook alerts, full end-to-end test as a customer). Audit each against the code, report gaps, and pair with a Codex final-diff review.
- **Compare with evidence.** Evaluate Codex findings against code, tests, documentation, schema state, and runtime behavior. Fix confirmed issues, investigate likely ones, and reject incorrect recommendations with evidence. Neither model's confidence is proof.
- **Implement narrowly.** Prefer the smallest correct solution, preserve existing behavior outside the requested scope, avoid speculative fixes and unrelated refactors, and add regression tests where appropriate.
- **Test-first for logic.** For anything that computes, stores or decides (data rules, calculations, sync jobs, security and database rules, bug fixes, and that kind of logic inside demos), write the test first, watch it fail, then write the code, so a wrong rule or number is caught before it ships. Visual changes, wording, design mock-ups and one-off data pulls are exempt. If the project has no test runner yet, adding the lightest one that fits is part of the first such change. The `test-driven-development` skill has the method.
- **Stop patch loops.** After repeated failed fixes, stop patching; reproduce the problem, gather evidence, re-evaluate assumptions, obtain an independent Codex diagnosis, identify the root cause, and then implement one evidence-based fix.
- **Definition of done.** Meaningful work is complete only after relevant behavior, tests, types, lint, builds, security boundaries, and migrations have been verified; Codex findings have been resolved when review was warranted; documentation is current; and no unrelated changes were introduced.
- **Human approval remains required** for destructive or irreversible production actions, production database changes, production deployments, secret changes, infrastructure deletion, spending, and genuine scope changes. The agents may prepare and verify these operations but must not execute them without approval.

# Delivery speed — size the work first
- **Pick a track before building, and say it in one line:** Fix (1–3 files; build directly; 15–30 min) ·
  Feature (one capability; build in-session, at most one helper agent; 60–90 min) · Batch (many independent
  items; the multi-agent pipeline, ≤ 90 min). A single feature does not go through a multi-agent pipeline:
  the pipeline's overhead is what once turned one feature into more than two hours.
- **Slice** risky backend from low-risk UI when each can ship alone.
- **One review round.** Codex reviews the whole final diff once, in parallel with rendered screenshots; one fix
  round; a second Codex look only for fixes touching auth/RLS/migrations/money. Leftovers go to the release
  gate, never another round. Code quality stays non-negotiable: tests, types, lint and the Codex review all run.
- **Check Codex quota at the start** of the review step; if it is exhausted, tell Akash immediately.
- **Time box.** At 1.5× the track budget, stop and tell Akash why, with options. Watch any running workflow
  every ~10 min and stop it on a second build round or a runaway fix loop.
- **Missing production data is a release-time check,** never a reason to rebuild.

# Loop reflexes — the system picks the loop, Akash never has to remember a command
Akash should never need to know that /goal, /loop, or /schedule exist. At these trigger moments, you compose and start (or offer) the right loop, fully written out:
- **Plan approved** → execute it AS a loop yourself: state the milestone's Verify criteria as the finish line, work-verify-fix until they pass or you're genuinely blocked. Never fall back to turn-by-turn "should I continue?" execution. Also hand Akash the ready-to-paste native line for harness-level enforcement — e.g. `/goal <the milestone's Verify criteria>, stop after 5 tries` — he should never have to compose it himself.
- **You just pushed a PR / shipped** → immediately start a babysit loop yourself (recheck PR reviews + CI every few minutes, fix what comes back, stop when merged/green). Tell Akash it's running; don't ask permission — it's in scope of the ship he asked for. If he'd rather not keep the session open, hand him the one-liner `/autofix-pr` (native cloud PR-watcher) ready to paste.
- **Waiting on something external** (CI, deploy, TestFlight processing, long build) → schedule your own wakeup and check it yourself. Never end with "let me know when it's done."
- **The same manual chore comes up for the second time** (a repeated check, report, cleanup, or QA pass) → propose ONE standing /schedule routine with the exact prompt prefilled, so Akash only says yes/no. If declined, drop it — don't re-propose.
- **Something external needs watching over time** (a page, pricing, a changelog, an inbox) → propose a firecrawl monitor once instead of doing repeated one-off checks.
- When a loop stalls or misfires, fix the cause in the system (a skill, a CLAUDE.md line, a Verify criterion), not just the instance. Add a rule only if it would have helped most recent sessions, not just this one, and prefer a setting or hook over more prose where the behaviour can be enforced.

# Memory discipline
- A project's auto-memory loads only when Claude is launched from that project's real directory under `~/Projects/`. If the session's working directory is not the project being discussed, say so once, and read that project's CLAUDE.md and memory index before answering about it.

# Web access — one hierarchy
- **Interactive browsing, QA, dogfooding a running site:** `/browse` (gstack). NEVER use `mcp__claude-in-chrome__*` tools.
- **Scraping, crawling, web search, structured extraction:** firecrawl skills.
- **Single quick fetch of a known URL:** built-in WebFetch is fine.
- If a plugin or skill description claims broader scope than this (e.g. "use for any webpage"), this hierarchy wins.

# One tool per job
- Spec → `/spec` · ideas → `/office-hours` · diff review → `/code-review` + Codex MCP · security → `/security-review` · web QA → `/qa` · visual QA → `/design-review` · browsing → `/browse` · scraping/search → firecrawl.
- Unused gstack skills are `"off"` in `skillOverrides` (settings.shared.json). Re-enable one only when a real task needs it; don't add a second tool for a job that already has one.

# Dynamic workflows
- Offer a dynamic multi-agent Workflow (the `Workflow` tool), with a one-line shape, for Batch-track work (many independent items) or unknown-size discovery, and wait for a yes. A single feature stays in-session (see Delivery speed). Say plainly when a workflow would be overkill (single-file/one-off/trivial).

# Custom skills
- Custom skills live in this repo under `skills/` and are symlinked into `~/.claude/skills/`. Run `~/suryavanshi-claude/sync.sh` after adding one.
