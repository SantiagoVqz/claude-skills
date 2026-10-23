# 2026-10-23 · vvfapp, KNOT, level8 · sv-build, sv-tdd, sv-worktree, sv-ui-check, sv-review, sv-verify, sv-diagnose, sv-ship, sv-pr, sv-cleanup, sv-setup-skills, sv-prototype, sv-unslop, sv-ask, sv-retro

vvfapp built #240 and #243, reviewed specs 230 and 231 twice each, and fixed bug #241. KNOT set up the skills again and cleaned up a branch. level8 ran sv-prototype three times and sv-unslop once, next to its own lvl8 skills. The user's notes in feedback.md on review, ui-check and prototype are merged into the findings.

## Sessions

- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp/5fbac915-deba-490a-be3d-8e3458a6a84a.jsonl · lines 1-433
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-level8/8bae5f87-00c1-437a-bcc8-87b117a25403.jsonl · lines 1-1215
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-Tonta-KNOT/f737c08d-a6ca-4b52-9a14-12907712c860.jsonl · lines 1-67
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-level8/140c67fe-485f-4d37-bfc1-27a5f63d97c6.jsonl · lines 1-10057
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-Tonta-KNOT/f77ac9cc-f202-44dd-a807-efe21de6f643.jsonl · lines 1-764
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-Tonta-KNOT/0143720e-6cca-489b-a57b-a052ac68e86c.jsonl · lines 1-729
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp--claude-worktrees-spec-230-documentos-en-el-detalle/161eceef-87b6-46c3-8506-89773c7374b6.jsonl · lines 1-973
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp/dc197665-b9bd-4573-a200-ae3c8d5bc699.jsonl · lines 1-129
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp/9d4b3bde-7d3f-4218-ab3a-be1783f2030e.jsonl · lines 1-2106
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp--claude-worktrees-spec-231-pieza-suajada/6eb049a1-6366-4ada-ac42-1de8c2dff519.jsonl · lines 1-3781
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp--claude-worktrees-spec-230-documentos-en-el-detalle/5e3ee9db-2a79-4958-8f7c-9b099afaa1ea.jsonl · lines 1-133
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-level8/cad7f48e-03df-4b0b-877e-5fe023de5f88.jsonl · lines 1-3371
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp--claude-worktrees-fix-241-metadata-emitidas-404/d3b3f9fa-9100-4587-8a6e-e8254976244f.jsonl · lines 1-1218
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp--claude-worktrees-ticket-243-segunda-deriva-pieza/35ad9935-771b-443d-b014-a9f8a5e3095a.jsonl · lines 1-694

## Findings

### F1 · sv-ui-check · DEVTOOLS.md Start · One shared DevTools profile lets one session break another

Status: applied
Seen in: 9d4b3bde, 6eb049a1, 161eceef (3 sessions), feedback.md, first time
What happened: The plugin runs chrome-devtools-mcp with no `--isolated`, so every session shares one profile. The skill offers "Kill <pid>", which breaks the other session's walk, and the killed session then gets only `about:blank`. Close leaves the window open, so it holds the profile for the next session.
Evidence: 9d4b3bde:1696: "The browser is already running ... Use --isolated to run multiple browser instances."; 6eb049a1:2707: "go ahead and show chrome devtools again pleas"; 6eb049a1:3776: "The DevTools tool lost its browser before I could blank the tab"
Fix: add a step: run chrome-devtools-mcp with `--isolated` from a user-level MCP server, in place of the plugin. In DEVTOOLS.md Start, remove "Kill <pid>". Answer "already running" with "the server is not isolated", then "Connect the extension" or "Skip the browser check". Close the page with `close_page` when it is not the last one.

### F2 · sv-prototype · UI.md step 3 · The pill switcher wins over a Figma-style canvas

Status: applied
Seen in: 5fbac915, cad7f48e, 140c67fe (3 sessions), feedback.md, first time
What happened: Each run had the Design type from quickstart and built plain HTML with the floating pill, because UI.md asks for it. The user asked for every iteration on one page with no pill, liked the side-by-side page, and the next run went back to the pill.
Evidence: 5fbac915:321: "a floating variant switcher instead of side-by-side artboards"; cad7f48e:2070: "do all iterations on the same page without need of clicking on the pill"; cad7f48e:2327: "I liked that design"
Fix: sharpen wording: replace UI.md step 3 with a canvas. Variants sit side by side as labelled frames, on the Design type when quickstart offers it. Each iteration is a new frame to the right of the one it changes. Remove the pill and the arrow keys.

### F3 · sv-ui-check · step 2 · The flow is not printed before the first call

Status: applied
Seen in: 9d4b3bde, 161eceef, 6eb049a1 (3 sessions), and 2026-10-21-vvfapp-knot-build-diagnose-review#F22 (2 runs)
What happened: The flow stayed in thinking or in the caller's arguments. The first visible call read the README or started a server.
Evidence: 9d4b3bde:1566: first call "grep ... README.md"; 161eceef:300: "sed -n '/^## Run/..."; 6eb049a1:3416: "Start the API in the background"
Fix: sharpen wording: make the printed flow the first item of the step 2 completion, also when a caller gave it. Add an Excuses row: "I have the flow in mind" / "The user cannot see thinking. Print it before the first tool call."

### F4 · project · backend tests · `API_SHARED_SECRET` in `.env` makes every API test answer 401

Status: open: the conftest fix is vvfapp work. The skill part, filing an environment fix with sv-issue, is applied.
Seen in: 9d4b3bde, 6eb049a1, 35ad9935, d3b3f9fa, 161eceef, 5e3ee9db (6 sessions), and 2026-10-21-vvfapp-knot-build-diagnose-review#F4 (2 runs)
What happened: Each session found the cause again, in 90 to 120 lines, and ran the tests with the variable empty. No issue was filed.
Evidence: 9d4b3bde:1176: "Every request answers 401"; d3b3f9fa:432: "That is outside this bug. I'll run the tests with the variable emptied"
Fix: project: vvfapp's conftest must clear `API_SHARED_SECRET`. Skill part: in sv-build step 6, sv-review step 3 and sv-diagnose step 3, file an environment fix with `sv-issue` once, when no open issue names it.

### F5 · sv-diagnose, sv-review, sv-ui-check · env files · A grep of `.env` printed the production password

Status: applied
Seen in: d3b3f9fa, 161eceef (2 sessions), first time
What happened: `grep DATABASE_URL backend/.env` also matched `PROD_DATABASE_URL` and printed its password. In another session a masked `cat .env` was refused by the classifier. sv-ui-check step 2 tells the agent to read the database URL from the env file.
Evidence: d3b3f9fa:180: "grep -h DATABASE_URL backend/.env"; d3b3f9fa:1085: "consider rotating it"; 161eceef:166: "[Credential Materialization]"
Fix: add a rule to the three skills: print no value from an env file. List names with `grep -oE '^[A-Z_]+=' <file>`. Take the dev database name and user from the provision output.

### F6 · sv-prototype · rule 4 and UI.md step 2 · Variants are not simple, not on the design system, or not on served data

Status: applied
Seen in: cad7f48e, 140c67fe (2 sessions), feedback.md, first time
What happened: Variants used iOS patterns the app does not use, chip clouds where a search field fits, and a copy of an existing calendar. The first version made up a Remind button that no endpoint serves, and showed far less data than the real account. The user asked for simpler UX four times.
Evidence: cad7f48e:2042: "It looks a bit too ios, please follow the design system."; cad7f48e:1311: "don't have too much visual info"; 140c67fe:6126: "don't have a calendar, we don't want to repeat components"; 140c67fe:3942: "no remind endpoint exists"
Fix: sharpen wording: in rule 4, read the project's design doc first and build from its components. In UI.md step 2, one variant is the simplest layout for the main task. Use one control pattern per form and a search field for a long list. Show only data and actions that the backend serves, and use the busiest real case.

### F7 · sv-prototype · UI.md step 4 · The link goes out before a rendered check

Status: applied
Seen in: cad7f48e, 140c67fe (2 sessions), first time
What happened: Pages went out with no render. A syntax check and the publish went in one call, so a broken page went live. Renders that did run found a clipped label, a card below the frame and duplicate row names.
Evidence: 140c67fe:5891: "the publish ran anyway because I sent both together"; cad7f48e:3164: "its top is 816 px down a 780 px frame"; 140c67fe:5932: "[P0] Rows with the same name."
Fix: add a step: run the script check and wait for it. Publish, open the page at the target width, and check each variant for clipped text, duplicate labels, small tap targets and empty, loading and error states. Fix what you find before you send the link.

### F8 · sv-verify · step 4 · A defect that a user can see is only a judgment call

Status: applied
Seen in: 6eb049a1, first time
What happened: Verify listed a lost form on a failed save and a false empty text as judgment calls, so the build did not fix them. sv-review then sorts the same defects as blocking and makes a sub-issue.
Evidence: 6eb049a1:2366: "A failed estilos fetch on save shows an error page and loses the typed values"; 6eb049a1:3025: "reads 'Todavía no hay cajas.', which is false"
Fix: add a step: add to the hard list "a defect that a user can see, or that stores or sends wrong data, that the diff caused", in the words of sv-review's Blocking kind.

### F9 · sv-build · steps 5 and 7 · The card grows past what the user can read

Status: applied
Seen in: 6eb049a1, 9d4b3bde (2 sessions), first time
What happened: The agent asked verify for the judgment calls that it cut and put the calls of both verify runs on the card: 11 calls. Another card had two "Check yourself" lists that disagreed, one with the live URL and one with `pnpm dev`.
Evidence: 6eb049a1:2387: "Send those two in full"; 9d4b3bde:1903: "Check yourself: `pnpm dev`"
Fix: sharpen wording: the card lists the judgment calls of the last verify run, as verify gave them. When sv-ui-check ran, its list replaces the card's "Check yourself".

### F10 · sv-tdd · step 1 · Prepare reads whole files, and the seam list is not printed

Status: applied
Seen in: 35ad9935, and 2026-10-21-vvfapp-knot-build-diagnose-review#F3 (2 runs)
What happened: Prepare read a 39 KB router and an 82 KB grep whole, and the context grew from 69k to 202k tokens before the first red. No `<criterion> · <seam> · <test file>` list was printed for the 17 criteria.
Evidence: 35ad9935:212: "Output too large (39.3KB)"; 35ad9935:426: "Starting cycle 1"
Fix: sharpen wording: read the parts that the criteria name, found with `grep -n`. Read a whole file only when it is the seam. The completion needs the seam list printed before the first red.

### F11 · sv-tdd · step 3 · The formatter runs after verify, not before

Status: applied
Seen in: 6eb049a1, first time
What happened: The first verify run had a hard Prettier finding on six files, so a second verify run was needed.
Evidence: 6eb049a1:2366: "`pnpm lint` failed: Prettier flags 6 files"
Fix: add a step: at the end of step 3, run the repo's formatter and lint, and commit the result.

### F12 · sv-review · step 7 · The follow-up ticket holds criteria that cannot both hold

Status: applied
Seen in: 35ad9935, first time
What happened: #243 says a save loads no estilos, and two other criteria assume that it does. The builder stopped to ask.
Evidence: 35ad9935:265: "Criterion 3 says a save and a live calculation load no estilos. Criteria 4 and 11 say the save loads them."
Fix: add a step: before publish, read the criteria of each ticket together, and settle each pair that conflicts.

### F13 · sv-review · step 1 · Long silent load

Status: applied
Seen in: 5e3ee9db, first time
What happened: The agent read the tracker, the spec and four tickets with no message, and the harness nudged it.
Evidence: 5e3ee9db:72: "The user hasn't heard from you in a while"
Fix: sharpen wording: after the load, send one line: full, partial or light, and the ticket count.

### F14 · sv-worktree · Make · A relative worktree path nests the worktree in the spec worktree

Status: applied
Seen in: 35ad9935, first time
What happened: The build started in the spec worktree, so `.claude/worktrees/<branch>` resolved inside it. The agent had to `git worktree move` it.
Evidence: 35ad9935:130: "The worktree landed nested inside the spec worktree."
Fix: sharpen wording: build the path from the primary checkout, the first `worktree` line of `git worktree list --porcelain`.

### F15 · sv-diagnose · steps 5, 6 and 10 · Hypotheses name fixes, and the card outgrows its template

Status: applied
Seen in: d3b3f9fa, first time
What happened: The top option combined two fix mechanisms, and the cause stayed unproven; verify said "diagnosis not proven". The card had three-sentence Cause and Fix lines and an extra section. The ADRs were listed with `ls` and not read.
Evidence: d3b3f9fa:553: "1+2: re-send 404, XML waits (Recommended)"; d3b3f9fa:1029: "diagnosis not proven"; d3b3f9fa:1039: "Also found, outside this fix:"; d3b3f9fa:111: "ls docs/adr/"
Fix: sharpen wording: a hypothesis names a cause, one option each. When no offline loop tests the cause, the card says "cause not confirmed" and names the real check. Cause and Fix are one sentence each, and other findings go to the report. A listing of `docs/adr/` does not count as a read.

### F16 · sv-setup-skills · PROVISIONING.md · The EnterWorktree hook provisions on teardown, and setup restores it

Status: applied
Seen in: f77ac9cc, 0143720e (2 sessions), first time
What happened: Remove calls EnterWorktree, and the hook booted a container and ran every migration seconds before `drop`. The user deleted the hook. The next setup recommended "Restore" and called the deletion an accident.
Evidence: f77ac9cc:709: "The hook booted a container as I entered. That is wasteful for a teardown"; 0143720e:140: "Restore (Recommended)"
Fix: sharpen wording: a commit that deleted an installed file is the user's choice: recommend "Leave deleted", and give no reason the commit does not state. Check whether sv-worktree Make already provisions, and if so remove the hook.

### F17 · sv-setup-skills · provision.sh · The port picker fails on a one-digit branch number

Status: applied
Seen in: f77ac9cc, first time
What happened: The check gave port `54` in place of `54NN`, and a branch with no number got the primary's backend port.
Evidence: f77ac9cc:483: "The route came out as port `54`, not `54NN`"; f77ac9cc:750: "gets backend port 8000. That is the primary's port."
Fix: add a step: compute the suffix as `10#$digits % 100`, and start at `01` when the branch has no digits.

### F18 · sv-setup-skills · steps 2 and 3 · A one-option tracker question, and `--force` resets label colors

Status: applied
Seen in: f77ac9cc, 0143720e (2 sessions), first time
What happened: Both runs asked which tracker to use, and the only other option was Stop. `gh label create --force` gave each label a new color.
Evidence: f77ac9cc:147: "Other: Stop."; 0143720e:261: "`--force` without `--color` reassigned the label colors."
Fix: cut a no-op: name the tracker in the summary, with no question. Sharpen wording: create only a missing label, and edit the description of a label that exists.

### F19 · sv-cleanup · preamble, steps 2 and 5 · Three cases the skill does not cover

Status: applied
Seen in: f77ac9cc, 0143720e (2 sessions), first time
What happened: ExitWorktree was a no-op after a `cd`. The skill named `--enable-merge-commit=false`, which KNOT's ADR forbids. The branch sat in the primary checkout, with no worktree.
Evidence: f77ac9cc:655: "No-op: there is no active EnterWorktree session to exit"; f77ac9cc:750: "ADR 0004 requires merge commits"; 0143720e:622: "it is checked out in the primary checkout"
Fix: sharpen wording: when ExitWorktree has no session, `cd` to the primary checkout. Name the merge setting only when no ADR needs merge commits. When the primary checkout has the branch, switch it to the trunk before the delete.

### F20 · sv-build · step 1 · Free-text ideas passed as the ticket

Status: applied
Seen in: f737c08d, first time
What happened: The user passed two ideas in place of an issue. The skill has no rule for that.
Evidence: f737c08d:7: "/sv-build viendo a mi madre usando la app, algunas ideas"
Fix: sharpen wording: when the argument is not an issue number or URL, stop and name `/sv-issue` to file it.

### F21 · sv-ui-check · step 2 and DEVTOOLS.md · Width, navigation and walk data

Status: applied
Seen in: 9d4b3bde, 161eceef (2 sessions), first time
What happened: `resize_page` left the page at 843px, and the report said 1280px. Pages were reached by typed URL. The seed script could not make the rows, so the agent wrote SQL, and the rows shared one `created_at`.
Evidence: 9d4b3bde:1815: "The window will not go under 843px"; 9d4b3bde:1903: "✓ Cliente at 1280px"; 161eceef:531: "My rows share one `created_at`"
Fix: sharpen wording: set a width with `emulate` and report the `innerWidth` the page shows. Type a URL only for the first page. When the seed script and the API cannot make the rows, use SQL in the fork, read `\d <table>` first, give each row the timestamps the list orders by, and restore each row you change.

### F22 · sv-build · step 9 · The final report leaves out what still runs

Status: applied
Seen in: 9d4b3bde, first time
What happened: The servers were stopped 170 lines before the report, and the user asked to stop them.
Evidence: 9d4b3bde:2085: "Please stop the servers."
Fix: sharpen wording: the report names what was stopped and what still runs.

### F23 · sv-prototype · description and setup · Trigger, platform question, servers and repo files

Status: applied
Seen in: cad7f48e, 5fbac915, 140c67fe (3 sessions), first time
What happened: The user had to ask for /sv-prototype three times, and one run built freehand with no Skill call. One run guessed the platform while the user was present. Dev servers stayed up. After the no-files rule, the agent still saved the HTML to `plans/mockups/` as the spec.
Evidence: cad7f48e:268: "Please do the /sv-prototype for this implementation before finishing the plan."; 5fbac915:417: "If you meant the web app, that is a different prototype."; cad7f48e:3109: "Please while you prototype stop the servers."; cad7f48e:2332: "save the approved design as the spec under `plans/mockups/`"
Fix: change the description: add "or before a UI change that the user must see first". Sharpen wording: ask one question when the surface is unclear and the user is present. Stop the servers this session started. Add an Excuses row: "The implementer needs the HTML" / "Give the artifact link and the decisions."

### F24 · sv-unslop · rules and report · Project jargon stays, and the report has the tells the skill removes

Status: applied
Seen in: 8bae5f87, first time
What happened: The rewrite kept "shadow unit" and "closed-vocabulary word", and the user asked three times for simpler words. The report used bold labels with colons. The rejected question was not rewritten.
Evidence: 8bae5f87:174: "Could you please explain this to me in simple terms"; 8bae5f87:200: "smaller"; 8bae5f87:164: "- **Bold labels:** each section used to start with a label"
Fix: add a rule: replace or define each project term that the reader did not write, and open a decision with one plain sentence. The report is one or two sentences under the same rules. When the user just rejected a message, rewrite that message too.

### F25 · sv-diagnose, sv-ship · outside skill · Real-data replay and a second-model review

Status: open: filed as #6 (sv-diagnose replay) and #7 (sv-verify second model).
Seen in: 8bae5f87, first time
What happened: lvl8 replayed the fixed rule, old against new, over the dev database copy of real data, and found the one collision. A second model with an attack brief found a high finding that the tests missed.
Evidence: 8bae5f87:698: "With the real data, the fix stops the refusal"; 8bae5f87:826: "The reviewer returned FIX-FIRST with one high finding"
Fix: add a step: sv-diagnose step 9 runs a differential replay over the dev data when it holds a recent copy of real data. sv-verify can run an optional second-model pass when the project has a second-model CLI.

### F26 · outside skill · knot-release · The set has no release skill

Status: rejected: a release flow is personal to KNOT and stays a KNOT skill. The "Keep" rule for a file that a repo skill reads is applied in sv-setup-skills.
Seen in: f77ac9cc, 0143720e (2 sessions), and 2026-10-21-vvfapp-knot-build-diagnose-review#F31 (2 runs)
What happened: Setup recommended deleting `announcement.md` because no sv skill read it. The user brought knot-release back.
Evidence: f77ac9cc:183: "No sv skill reads it"; 0143720e:325: "bring back the release skill since that one is very useful for deployments"
Fix: propose a new skill: `sv-release`. Until then, setup recommends "Keep" for a file that a kept project skill reads.

### F27 · sv-retro · step 6 · Findings summed up in one line before approval

Status: applied
Seen in: 5fbac915, first time
What happened: The chat covered 14 findings in one line, and the user approved all 31 with one word.
Evidence: 5fbac915:230: "The other 14 findings ... are single-session wording fixes"
Fix: sharpen wording: show one line per finding in the chat.

## Worked

- sv-tdd step 2: each red was checked for the right reason, and a test that passed first got a deliberate break (9d4b3bde, 6eb049a1, 35ad9935).
- sv-tdd step 1: the agent asked one question with a recommendation on conflicting criteria and did not guess (35ad9935:265).
- sv-diagnose: a flaky loop was measured over 30 runs and pinned to 10 of 10 red; each hypothesis was tested alone; the revert made all four regression tests fail (d3b3f9fa).
- sv-build step 5: verify ran in a fresh subagent each time, and the judgment calls reached the card.
- sv-worktree Make and Remove: the spec link, provision and teardown ran in order (9d4b3bde, 6eb049a1, f77ac9cc).
- sv-setup-skills: the summary came first and each choice had its own question, so 2026-10-21#F27 and #F28 held (f77ac9cc, 0143720e).
- sv-ui-check: the agent read the URL and the code before a ✗, waited for the user to sign in, and named its rows under Data (161eceef).
- sv-ask: it read the state from git, gh and the docs and asked no question (dc197665).
- sv-prototype rule 6: each change went to the same artifact link (140c67fe, cad7f48e).
- sv-pr: Evidence, Merge Danger and the closing lines followed the template (d3b3f9fa, f77ac9cc).
