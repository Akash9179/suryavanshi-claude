---
name: design-references
description: Use when doing any UI or design work — exploring design ideas, brainstorming a look, building or restyling an interface — or when Akash asks for "high quality" or a design review.
---

# Design references

## Reference library

Ground tokens/type/spacing/aesthetic in a real DESIGN.md before proposing or building. Sources, in order:

1. **Refero Styles** — https://styles.refero.design — 2,000+ DESIGN.md files from real product sites, filterable by aesthetic (Minimal, Clean SaaS, Editorial Type, Soft Gradients, Monochrome, Premium). Search by brand name or aesthetic, open the style page, and scrape it (firecrawl) for the full spec. Start here.
2. **awesome-design-md** — https://github.com/voltagent/awesome-design-md — ~80 hand-analyzed specs (Apple, Airbnb, Linear, Stripe, Vercel, Notion, Figma, Spotify, Nike…). Raw fetch:
   ```
   https://raw.githubusercontent.com/voltagent/awesome-design-md/main/design-md/<name>/DESIGN.md
   ```
   (List folder names via the GitHub contents API for `design-md/`.)
3. **URL → DESIGN.md extractor** — https://www.sokosumi.com/tools/design-md — free, no key. Use when the reference site isn't in either catalog, or when Akash says "make it look like <url>". designmd.me is the credit-gated alternative with Figma import.

## Quality bar

When Akash says he wants **high quality** or asks for a **design review**, treat that as a hard bar: pick the closest reference(s) from the collection, extract their concrete tokens, and match that level — do not ship generic/AI-default UI.

## Default taste target

Modern, luxurious, simple — Apple/Airbnb-grade. Light canvas, generous whitespace, ONE restrained accent, clean geometric sans, photography-first. Avoid dark-editorial-by-default unless asked.
