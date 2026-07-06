---
name: executing-hard-tasks
description: Use when starting any multi-step or unfamiliar task, when an instruction conflicts with what the code, comments, or tests say, before reporting any work as done, or when blocked and unsure what to do next.
---

# Executing Hard Tasks

## Overview

Work in a loop: **scout → decompose → act → verify → decide**. The expensive failures are not bad edits — they are acting on unexamined assumptions and reporting success that was never checked.

## Scout before you decompose

Cheap reconnaissance first — under 10% of the task:

1. State what "done" means as something checkable (a command that passes, an output that matches).
2. Read the actual target before changing it: the file, the comments around the change site, tests that mention it, its callers.
3. Size the work with a cheap probe (ls, grep counts, one representative example) before committing to an approach.

Then decompose along independence lines: pieces that can be done and verified separately. Sequential when each step informs the next; parallel only when steps share no state. Keep the work list written down (todos), not in your head.

## Instruction vs evidence — the stop rule

While working, compare what you were told with what you find. **If the repo contradicts the instruction — a comment saying "do not change this", a test asserting the opposite, history showing it was reverted — stop and surface the conflict. Recommend a direction; do not implement silently.**

- Do not edit the comment or test to make the instruction true.
- Do not mark the task done "as instructed" — the conflict IS the deliverable.
- If both directions are genuinely safe and reversible, pick one, but state the conflict prominently in your report, not as a buried caveat.

| Rationalization | Reality |
|---|---|
| "The user explicitly told me to change it" | The user hasn't seen the warning you just saw. Telling them is the job. |
| "Docs and code now agree" | You made them agree by re-introducing the thing the code warned about. |
| "I'll mention it in passing" | A caveat buried under a "done" is a silent change. Lead with the conflict. |

## Verify before you say done

"Done" is a claim about evidence, not effort:

- Find the repo's own checks even when nobody mentioned them — look for test files, run/build scripts — and run them.
- Verify at the behavior layer: exercise the flow you changed, not just the compiler or a re-read of your diff.
- Report what you ran and what it output. If a check fails, the status is not done — say so plainly.

**REQUIRED BACKGROUND:** superpowers:verification-before-completion (evidence before claims), superpowers:systematic-debugging (when a check fails and you don't know why).

## Decide what to do next

- Evidence and instruction agree, action reversible → act; don't ask.
- New information invalidates the plan → re-plan now; don't push through on sunk cost.
- Blocked → try a second angle, then a third, before escalating. Ask the user only when the decision is genuinely theirs: irreversible, spends money, or changes scope.
- Before ending your turn: if your last paragraph promises work ("I'll…", "next I would…"), do that work instead of ending.

## Red flags — stop and re-check

- About to change a line with a warning comment beside it
- Writing "now agree" or "as requested" while a repo check fails
- Claiming done without having run anything
- Asking the user something a file in the repo could answer
