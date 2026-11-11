# Template: Codex browser QA brief (features, function, UI and UX)

How to use:
1. Copy this file into the project, for example `docs/qa/codex-pass/BRIEF.md`.
2. Ask Claude to fill every `{{…}}` from the project's routes, fixtures and access rules. Claude reads the
   app's router for the screen list and the app's buttons and forms for the flows.
3. Delete any section that does not apply (for example Phase B when the app has one role).
4. Paste the message in section 9 into Codex.
5. When Codex finishes, tell Claude: "Read the Codex findings and fix them."

---

# Brief for Codex: full test of {{APP NAME}} on {{ENVIRONMENT}}

You are an independent QA tester. You control {{OWNER}}'s browser. You test a web app by hand, like a
careful human tester, and you write down every problem you find. You test two things with equal weight:
**does each feature work correctly from start to finish** (section 4), and **is it easy and pleasant to
use** (section 3). You do not fix code. Another engineer (Claude) reads your report and fixes the
problems. Your report is the only thing that engineer sees, so it must be complete and exact.

## 1. The app

- **What it is.** {{ONE OR TWO SENTENCES: WHO USES IT AND FOR WHAT}}
- **Where.** {{ENVIRONMENT}} only: **{{TEST URL}}**
- **Roles.** {{ROLES, FOR EXAMPLE: CLIENT, ADMIN}}
- **Data.** {{IS THE DATA FICTIONAL? WILL IT BE RESET AFTER THE TEST?}}
- **Sign-in.** {{HOW SIGN-IN WORKS, AND ANY LIMIT ON SIGN-IN E-MAILS OR CODES}}. {{OWNER}} signs you in
  for each phase (section 5).

## 2. Hard rules (stop and ask {{OWNER}} if a rule blocks you)

1. **Use only `{{TEST URL}}`.** Never open or touch {{LIST: PRODUCTION URL, ADMIN DASHBOARDS, HOSTING,
   DATABASE, GIT HOSTING, PAYMENT OR MAIL PROVIDERS}}.
2. **Do not sign out, and do not request a sign-in code or link.** If you lose the session, stop and ask.
3. **Type only fake e-mail addresses that end in `.example`.** Never type a real address in any form.
4. **Do not change, deactivate or delete these accounts:** {{OWNER'S AND REAL PEOPLE'S ACCOUNTS}}, and
   the account you are signed in as.
5. **Do not confirm these actions:** {{IRREVERSIBLE OR DANGEROUS ACTIONS: PERMANENT DELETE, EMERGENCY
   ACCESS, JOB RUNNERS, PAYMENTS, ANYTHING THAT SENDS TO REAL PEOPLE}}. Open those screens and judge
   them, but do not confirm.
6. **Payments:** {{"NONE IN THIS APP" OR "TEST CARDS ONLY, FOR EXAMPLE 4242 4242 4242 4242, AND ONLY
   IN TEST MODE"}}.
7. **Uploads:** use only small files you make yourself. Never upload a file from {{OWNER}}'s disk.
8. **Do not read, print or copy secrets, cookies, tokens or storage values.** Do not paste a session
   token or sign-in link into your report.
9. **Do not change code, config or git** in any repository. You only test and report.
10. **E-mail budget:** {{LIMIT, FOR EXAMPLE "AT MOST 3 E-MAILS IN TOTAL FROM INVITES AND RESENDS"}}.
11. **Before every destructive click,** write in your notes what you will click and why the rules allow it.

## 3. Screen checks: what to look at on every screen

Test every screen in section 5. For each screen, check all of these:

- **Function.** Every button, link, form, filter, tab, sort, search and dialog does what its label says.
  Try valid input, empty input, very long input (200+ characters), and odd input (emoji, `<b>x</b>`,
  leading spaces). Try double-clicks on submit buttons.
- **States.** Loading, empty, error and success states. A page with no data must say so clearly.
- **Layout at three widths:** 1280 px (desktop), 768 px (tablet) and 390 px (phone). Look for overflow,
  horizontal scroll, clipped or overlapping text, hidden buttons, and tap targets smaller than about 40 px.
- **Light and dark theme,** if the app has both. Look for low contrast, invisible borders and white flashes.
- **Keyboard.** Tab through each page. Focus is visible and in a sensible order. Dialogs trap focus and
  close with Escape. Forms submit with Enter.
- **Copy.** Spelling, grammar, jargon a normal user would not understand, different words for the same
  thing, and odd date or number formats.
- **Consistency.** The same component looks and acts the same everywhere.
- **Navigation.** Back, Forward, reload, and opening a deep link in a new tab all work.
- **Console and network.** Report any red console error, failed request (4xx or 5xx) or request slower
  than 3 seconds.
- **Access.** As the lowest role, type higher-role URLs and IDs that belong to other users. The app must
  show a plain "not found" or "no access" page and never show data that is not the user's.

## 4. Feature tests: end-to-end flows

A feature passes only when the whole flow works and **the result shows up in every place it should**:
{{LIST THE PLACES, FOR EXAMPLE: THE OTHER ROLE'S VIEW, THE ACTIVITY LOG, THE E-MAIL LOG, AFTER A
RELOAD}}. A "Saved" message on screen is not proof. Write a row in the "Flows" table (section 7) for
each flow, and a finding for every fail. If the intended behaviour is unclear, test what is reasonable
and write the question in "Questions for Claude". Undo each change after you check it, unless a later
flow needs it.

### {{ROLE 1}} features (Phase A)

| ID | Flow | Check |
|---|---|---|
| A-01 | {{FLOW NAME}} | {{STEPS, AND WHAT MUST BE TRUE AFTERWARDS, AND WHERE}} |
| A-02 | {{…}} | {{…}} |

### {{ROLE 2}} features (Phase B)

| ID | Flow | Check |
|---|---|---|
| B-01 | {{FLOW NAME}} | {{…}} |

Good flows to include in most apps: sign-in landing page, create, edit, delete or archive and restore,
search and filters, upload and download, invite and permissions, settings that must survive a reload,
notifications or e-mails, export, and a change by one role that another role must see.

## 5. Order of work and screens

One browser session holds one sign-in, so the phases run one after another. {{OWNER}} signs you in at
the start of each phase.

### Phase A: {{ROLE 1}} (signed in as {{ACCOUNT}})

| Route | What it is |
|---|---|
| `{{/route}}` | {{…}} |

### Phase B: {{ROLE 2}} (signed in as {{ACCOUNT}})

| Route | What it is |
|---|---|
| `{{/route}}` | {{…}} |

### Phase C (optional): re-check Phase A's view after Phase B's changes

Inside each phase: run the feature flows first at 1280 px in light theme, then the screen checks on every
screen at all widths and both themes. Update `findings.md` after each flow and each screen.

## 6. Evidence

- Save one screenshot for every finding in `{{ABSOLUTE PATH}}/shots/`, named `F-001-short-name.png`.
- Crop or blur any real e-mail address, name or personal data before you save a screenshot.

## 7. The report (this is what Claude reads)

Write one file: `{{ABSOLUTE PATH}}/findings.md`. Update it as you go. Use exactly this shape.

```markdown
# Codex QA pass: <date>, {{ENVIRONMENT}}

Build tested: <commit or deploy id if shown, else "unknown">
Browser: <name and version>
Phases done: A, B, C (strike what you did not do)

## Summary
- Findings: <n> total: <n> blocker, <n> high, <n> medium, <n> low
- Flows: <n> pass, <n> fail, <n> not run
- Top 3 problems, one line each

## Findings

### F-001 · <severity> · <area> · <one-line title>
- **Where:** <full URL>, <width>, <theme>, <role>
- **Steps:** 1. … 2. … 3. …
- **Expected:** <what should happen>
- **Actual:** <what happens, with exact on-screen text in quotes>
- **Console/network:** <exact error text and failing request, or "none">
- **Screenshot:** shots/F-001-<name>.png
- **Repeats:** <always / sometimes (n of m tries)>

## Flows
| ID | Flow | Result | Findings | Notes |
|---|---|---|---|---|
(one row per flow in section 4)

## Coverage
| Screen | 1280 | 768 | 390 | Light | Dark | Keyboard | Notes |
|---|---|---|---|---|---|---|---|
(one row per screen in section 5; ✗ for not tested, with the reason)

## Not tested and why

## Questions for Claude
```

| Severity | Meaning |
|---|---|
| **blocker** | A user cannot finish a main task, data is lost, or a user sees data that is not theirs |
| **high** | A main task works but is broken, confusing or wrong in a way users will notice |
| **medium** | A visible defect with a workaround: layout breaks at one width, a missing state, unclear copy |
| **low** | Polish: spacing, small wording, minor inconsistency |

Areas: `feature`, `function`, `layout`, `theme`, `a11y`, `copy`, `consistency`, `navigation`,
`performance`, `access`, `error-handling`.

Report rules:

- One problem per finding. If it repeats on many screens, write it once and list every URL.
- Write what you saw. Label any guess about the cause as **Guess:**.
- Quote on-screen text exactly.
- Taste is not a defect. Put design opinions in "Questions for Claude".
- When you finish, reply with the Summary, the Flows table and the path of the file.

---

## 9. Message to paste into Codex

```
You are doing an independent test of a web app by driving my browser. Test both: whether every feature works correctly from start to finish, and the UI/UX of every screen. Do not change any code.

Read this file first and follow it exactly:
{{ABSOLUTE PATH}}/BRIEF.md

Key points (the brief has the full rules):
- Test only {{TEST URL}}. Never open {{FORBIDDEN PLACES}}.
- I sign you in. Do not sign out and do not request a sign-in code. If you lose the session, stop and ask me.
- Type only fake e-mail addresses ending in .example. {{E-MAIL BUDGET}}.
- Never confirm {{DANGEROUS ACTIONS}}.
- In each phase, run the feature flows in section 4 first, then the screen checks in section 3.
- A feature passes only when its result shows in every place it should, including after a reload.
- Write findings to {{ABSOLUTE PATH}}/findings.md as you go, in the format of section 7, with screenshots in shots/.

Start with Phase A. I will sign you in as {{ACCOUNT}} and tell you when you are signed in. Before you begin, reply with:
1. The tool you will use to control the browser.
2. Your test plan in five lines or fewer.
Then wait for my "go".
```
