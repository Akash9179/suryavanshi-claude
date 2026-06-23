---
name: copyedit
description: Editorial review of English prose/copy — grammar, clarity, concision, active voice, parallelism, consistency, tone, and AI-slop/cliché detection. Use when reviewing or polishing user-facing copy (landing pages, marketing, docs, UI strings, emails) or when the user asks "is this correct English", "review the copy/writing", "proofread", or "tighten this".
---

# Copyedit — editorial review of English prose

Review copy like a sharp human editor: catch real grammar errors, then tighten
for clarity and voice. Separate **errors** (objectively wrong) from **style**
(defensible but improvable) so the user can decide. Never silently rewrite —
propose, with the reasoning, and let the user choose.

## When to use it

- The user asks "is this correct English?", "proofread", "review the copy",
  "tighten this", "does this read well?"
- After writing or changing any user-facing copy (landing page, marketing,
  UI strings, emails, docs).
- Reviewing a whole site/page's text for quality and consistency.

## How to run it

1. **Collect every piece of user-facing copy** in scope. For a website, read the
   source and pull headings, body, taglines, button labels, alt text, meta
   (title/description/OG), and form labels/placeholders. Don't review code or
   comments — only what a reader sees.
2. **Run each line through the checklist below.** Go in reading order so flow
   issues surface.
3. **Report findings** in the output format below. Be specific and quote the
   exact text. Recommend, don't impose.
4. **Apply only what the user approves.** Treat any copy the user has marked as
   "locked"/"final" as off-limits unless they reopen it — flag issues there but
   don't change without an explicit OK.

## Checklist (per line)

- **Grammar & syntax** — subject/verb agreement, tense consistency, pronoun
  reference, dangling modifiers, run-ons/fragments, **elliptical constructions**
  that read as incomplete (e.g. trailing "…that people used to").
- **Clarity & ambiguity** — could a sentence be read two ways? Is the meaning
  buried? Is a phrase non-standard (e.g. "put capability forward" — "put
  forward" means *propose*, not *advance*)?
- **Concision** — cut filler ("in order to", "the fact that"), redundancy, and
  hedging. Shorter is stronger.
- **Active voice & strong verbs** — flag passive constructions and weak
  verbs ("is", "makes", "provides") where an active verb is sharper.
- **Parallelism** — items in a list or paired phrases must share grammatical
  form. Watch for **zeugma** (one verb forced across two meanings, e.g. "put
  capability forward and people out of harm's way").
- **Consistency** — one spelling system throughout (US vs **British/Indian**:
  defence/programme/organisation), consistent terminology, capitalization,
  punctuation (Oxford comma, en/em dashes, curly vs straight quotes).
- **Tone & register** — confident and concrete. Flag **AI-slop / hype clichés**:
  "cutting-edge", "robust", "seamless", "world-class", "years ahead of the
  competition", "revolutionize", "delve", "in today's fast-paced world".
- **Word choice** — wrong word (affect/effect, comprise/compose), tired idiom,
  jargon a reader won't know.

## Output format

Group by severity. For each finding:

```
[ERROR | STYLE] "<exact quoted text>"  (<location, e.g. hero h1 / footer>)
  Issue: <one line — what's wrong and why>
  Fix:   "<suggested rewrite>"
```

End with: a one-line **verdict** (is the copy fundamentally sound?), and the
**consistency call** (which spelling system the copy uses, and whether it holds
throughout).

## Notes

- **Errors first, style second.** Don't bury a real grammar error under nitpicks.
- **Preserve voice.** Rewrites should sound like the surrounding copy, not
  generic. For a bold brand, keep the edge — just make it correct.
- **Don't over-edit.** If a line is already strong, say so and move on. Flagging
  everything dilutes the real issues.
- When unsure between two good options, present both and recommend one.
