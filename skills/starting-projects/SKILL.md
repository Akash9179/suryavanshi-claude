---
name: starting-projects
description: Use when creating a new project or repository from scratch — a new app, service, site, or experiment — before writing any feature code.
---

# Starting Projects

## Overview

A new project is scaffolded for autonomous execution, not just for code. Test: a fresh agent session must be able to answer — what is this, how do I run it, what is the current milestone, how do I verify my work, and what may I do without asking — using only files in the repo.

You already know to git init, write a README/.gitignore, and set up docs/plans with owner-decision gates. The four things sessions consistently forget:

## 1. Seed `.claude/settings.json` with the project's routine permissions

Hands-off execution dies at the first permission prompt while the owner is away. When the stack is chosen, allow its routine commands:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run:*)", "Bash(npm test:*)", "Bash(npx:*)",
      "Bash(git add:*)", "Bash(git commit:*)"
    ]
  }
}
```

Adjust to the real toolchain (bun/pnpm/xcodebuild/pytest…). Routine-only: never seed deploys, deletes, or force-pushes.

## 2. Done-criteria are part of the plan, not vibes

Every milestone in the plan gets a **Verify:** line — a command to run or a behavior to exercise, checkable by an agent without the owner. CLAUDE.md gets a "Verification" section pointing at the same recipe. A plan whose milestones have no Verify lines is not ready for owner approval.

## 3. Persist planning decisions to memory before building

When the owner approves the plan, write the load-bearing decisions (stack, constraints, milestone definitions, anything a future session would re-ask) to the project's auto-memory, and keep its MEMORY.md index line current. The repo holds the spec; memory holds the "why" and current state.

## 4. Propose the house defaults — the owner disposes

Don't present a blank slate. Open planning with the shared-practice defaults already penciled in, as proposals the owner can override: web → Next.js + Vercel + Supabase (plugins are installed); iOS/macOS → SwiftUI; design → the shared taste target grounded in awesome-design-md (see the shared CLAUDE.md). Genuinely open questions (data sources, scope, pricing) stay open.

## Done means

- `.claude/settings.json` exists with routine allows for the chosen toolchain
- Every plan milestone has a Verify line; CLAUDE.md has a Verification section
- Approved-plan decisions are in project memory, indexed
- The planning doc shows house defaults as pre-filled proposals, not blanks
