# 2026-10-21 · vvfapp, KNOT · sv-build, sv-tdd, sv-worktree, sv-ui-check, sv-review, sv-diagnose, sv-ship, sv-pr, sv-cleanup, sv-setup-skills

Five vvfapp sessions built tickets 233, 234, 236 and 237 with sv-build and sv-tdd, and reviewed spec 231 with sv-review. Two KNOT sessions fixed a seating-plan bug with sv-diagnose, sv-ship and sv-cleanup, and started sv-setup-skills.

## Sessions

- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-Tonta-KNOT/92edf03f-b330-4513-b633-b5f7258eeb37.jsonl · lines 1-127
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp/8b1d0077-d24b-4342-b065-577193f3b1fe.jsonl · lines 1-1238
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp/9a970d79-fc44-477d-be8b-2bf3358b0100.jsonl · lines 1-862
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-Tonta-KNOT/d13fd348-68d6-4c9d-a0f8-63827641e3dc.jsonl · lines 1-918
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp/46161423-5fc8-4c25-bc23-f03f9fff87ff.jsonl · lines 1-2078
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp--claude-worktrees-spec-231-pieza-suajada/e03bd75e-0837-4fd4-9c42-98cba37d3544.jsonl · lines 1-1071
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp/2338aae5-dcb5-452b-845b-d2eb1e4ee7d5.jsonl · lines 1-1508

## Findings

### F1 · sv-build, sv-worktree, sv-review, sv-tdd · shell rules · Files are changed by heredoc scripts, and the guard refuses only some of them

Status: applied
Seen in: 8b1d0077, 9a970d79, 46161423, 2338aae5, e03bd75e (5 sessions), first time
What happened: After EnterWorktree, the agent changed source files with `python3 - <<'EOF'`, `sed -i` and `cat >>` scripts, and it ran `&&` and `;` chains. The skills say that the guard refuses these. The guard let most of them run. It refused a `cat >>` heredoc twice. In one session the Edit tool then found a file changed behind its back.
Evidence: 8b1d0077:358: "uv --directory backend run python - <<'EOF' ... p=pathlib.Path(\"tests/test_cajas.py\")"; 8b1d0077:641: "the file had been modified on disk since you last read it"; 9a970d79:526: "python3 - <<'EOF' p='frontend/src/lib/components/ResultadoCaja.svelte'"; 46161423:695: "this command is too complex to verify that it stays inside the worktree. Refusing to run it"; 2338aae5:225: "Refusing to run it"; e03bd75e:805: "mkdir -p ... && mv .ficha.json ..."
Fix: sharpen wording: test what the guard refuses today, and state only that. Change the rule in sv-build, sv-worktree step 3, sv-review and sv-tdd step 2 to: "Change a file with the Edit tool. Make a new file with the Write tool. Do not change a file with a heredoc, `sed -i`, `python3 -` or `cat >>`. Quote each path that holds `[` or `]`." Add an Excuses row to sv-build: "The guard allowed the command" / "The guard does not catch every command. The rule is one plain command per call."

### F2 · sv-tdd · step 3 · The refactor step says the code reads clean, then verify finds duplication

Status: open
Seen in: 8b1d0077, 9a970d79, 2338aae5 (3 sessions), first time
What happened: The agent read a sample of the code, or only fixed lint, and said that no refactor was needed. Each time, verify then found duplication: a copied loader, a copied formatter, or four checks that decide the same case in four ways. Each copy shipped as a judgment call.
Evidence: 8b1d0077:1015: "The diff reads clean. I see no refactor worth a commit."; 8b1d0077:1040: "Four checks decide \"is a pieza\" in four ways"; 9a970d79:670: "The code reads clean, no refactor commit needed."; 9a970d79:705: "`pesos` rebuilds the es-MX narrowSymbol formatter that Dinero.svelte already has."; 2338aae5:600: "Refactor: format the cliente page spec with Prettier"; 2338aae5:639: "`remisionesDe` copies proveedores/[id]/+page.server.ts:54 line for line"
Fix: sharpen wording: in step 3, write "Read `git diff <base>...HEAD` in full. For each new helper, search the codebase for one that does the same job. Compare the new code with the code of earlier tickets of the same spec. List each place that branches on the new case." Add an Excuses row: "The code reads clean" / "Name the diff you read and the helpers you searched for. Formatting is lint, not refactor."

### F3 · sv-tdd · step 1, and sv-diagnose · step 3 · The glossary and the ADRs are not read, and seams are not named

Status: open
Seen in: 8b1d0077, 46161423, 2338aae5, d13fd348 (4 sessions), first time
What happened: The agent did not read the glossary and the ADRs for the area, or grepped the glossary for a few terms only. It did not write a seam for each criterion. In 46161423, a word from the glossary's Avoid list went into names and a UI label and cost two verify rounds. In 8b1d0077, a seam case from the spec got no test. In d13fd348, the fix broke a glossary term.
Evidence: 46161423:209: "grep -n -i \"direcci\|emitida\|recibida\|maquiladora\|planta\|pendiente\" CONTEXT.md"; 46161423:1339: "CONTEXT.md:388 \"Participante, _Avoid_: parte, contraparte\""; 8b1d0077:1040: "No test checks a pieza in `GET /api/cajas`."; 2338aae5:143: "Now the cliente route" (no read of CONTEXT.md or docs/adr in lines 111-190); d13fd348:491: "CONTEXT.md says \"adjacent seats\""
Fix: sharpen wording: change the sv-tdd step 1 completion to "You wrote one line for each criterion: criterion · seam · test file. You read the glossary and the ADRs that domain.md names for the area. You looked up each noun for a test, a component or a label, and each English word of the spec, in the glossary and its Avoid lists." Put the same glossary and ADR read into the sv-diagnose step 3 completion.

### F4 · project · test harness · Backend tests are not isolated from the environment

Status: open
Seen in: 8b1d0077, 46161423, e03bd75e (3 sessions), first time
What happened: `backend/.env` sets `API_SHARED_SECRET`, and `conftest.py` does not clear it, so every backend test answers 401. The fixture truncates after each test, not before, so a killed run leaves rows. All worktrees share one Postgres container, so concurrent suites took 63 and 64 minutes. One session also had to install the headless Chromium for vitest.
Evidence: 8b1d0077:332: "The backend suite fails at baseline with 401s."; 46161423:297: "this machine's `.env` sets it."; e03bd75e:270: "The fixture truncates after each test, not before."; 46161423:1886: "The run took 64 minutes under load"; 46161423:728: "The headless Chromium for this Playwright version is not installed."
Fix: project.

### F5 · sv-ui-check · step 2 · The walk starts with no data

Status: open
Seen in: e03bd75e, 2338aae5 (2 sessions), first time
What happened: The worktree database had no clientes, cajas or remisiones. In both sessions the agent asked the user how to get data. In 2338aae5 it then spent about 200 transcript lines on forms. It also guessed the database user.
Evidence: e03bd75e:529: "clientes 0 cotizaciones 0 cajas 0"; e03bd75e:513: "could you please provision some data in general so we can visualize the app."; 2338aae5:826: "the local data has no clientes or remisiones. How should I get sample data?"; 2338aae5:723: "role \"postgres\" does not exist"
Fix: add a step: before the first browser step, check that the database holds the rows the flow needs. When it does not, make the fewest rows the flow needs through the project's seed script or the API, without a question, because the fork is disposable. Name the rows in the report. Project part: `scripts/seed-dev.sh` seeds only the company and its users, and `vvfapp` is empty until `scripts/db.sh pull` runs.

### F6 · sv-ui-check · step 2 · The DevTools paragraph does not cover the common failures

Status: open
Seen in: e03bd75e, 2338aae5 (2 sessions), first time
What happened: A Chrome process from another session held the DevTools profile. In 2338aae5 the agent hit that error three times and asked three questions. The agent set input values with `evaluate_script`, which did not trigger the app's handlers. It guessed a route that does not exist. Screenshots and snapshots with a scratchpad path were refused. A script ran before the navigation ended. An expired Clerk session first looked like an app failure.
Evidence: 2338aae5:821: "The browser is already running for .../chrome-devtools-mcp/chrome-profile"; 2338aae5:885: "fails the same way for the third time"; e03bd75e:665: "The click did not open the disclosure. I open it by script."; e03bd75e:859: "That URL is not a route."; 2338aae5:1167: "is not within any of the configured workspace roots"; 2338aae5:1215: "Cannot set properties of null"; e03bd75e:729: "The session dropped: the reload landed on sign-in."
Fix: sharpen wording: in the DevTools paragraph, write: "When a tool answers 'The browser is already running', run `pgrep -fl chrome-devtools-mcp/chrome-profile` and ask one question: kill the pid, connect the extension, or skip the browser check. Change the page only with `click`, `fill` and `fill_form`. Use `evaluate_script` only to read. Reach a page through its links. Take screenshots and snapshots with no file path. Send the next call only after `navigate_page` returns. Before you mark a step ✗, read the URL and the console. When the page went to sign-in, ask the user to sign in again and redo the step."

### F7 · sv-build · step 8 · No rule for a spec branch that has no worktree

Status: open
Seen in: 8b1d0077, 46161423 (2 sessions), first time
What happened: Step 8 says to enter the spec worktree, but none existed. In both sessions the agent made one with a plain `git worktree add`, outside sv-worktree.
Evidence: 8b1d0077:1079: "The spec branch has no worktree yet, so I'll make one."; 46161423:1908: "no spec worktree exists yet, so I make one from the primary checkout."
Fix: add a step: in step 8, write "When the spec branch has no worktree, make it with the `sv-worktree` skill. Keep it, because the next ticket lands there too."

### F8 · sv-build · step 9, and sv-setup-skills · tracker-github.md · The Close command does not fit a multi-line comment

Status: applied
Seen in: 8b1d0077, 46161423 (2 sessions), first time
What happened: The tracker template gives `gh issue close --comment "..."`. The guard refused the multi-line form in 8b1d0077. In 46161423 the agent tried a `--comment-file` flag, which does not exist. Both sessions then posted the comment from a file and closed the issue after it.
Evidence: 8b1d0077:1157: "what it run[s] cannot be shown not to be git. Refusing to run it"; 46161423:1989: "unknown flag: --comment-file"
Fix: sharpen wording: in sv-build step 9 and in the template, write "Write the comment to a file with the Write tool. Run `gh issue comment <n> --body-file <file>`, then `gh issue close <n> --reason completed`. Delete the file." vvfapp's `docs/agents/tracker.md` needs the same line.

### F9 · sv-worktree · Make step 1, and sv-build · step 2 · No case for a spec branch that is only on the remote

Status: open
Seen in: 8b1d0077, 46161423 (2 sessions), first time
What happened: sv-build step 2 says that the ticket starts from `origin/<spec-branch>`. sv-worktree says to use the local spec branch. Neither skill covers a spec branch that exists only on the remote. Both sessions made the tracking branch by hand.
Evidence: 8b1d0077:64: "spec branch exists only on the remote"; 8b1d0077:84: "git branch --track spec/231-pieza-suajada origin/spec/231-pieza-suajada && git worktree add ..."
Fix: sharpen wording: in sv-worktree Make step 1, write "When the spec branch is only on the remote, run `git branch --track <spec-branch> origin/<spec-branch>` first." Make sv-build step 2 say the same.

### F10 · sv-build · step 4, and sv-tdd · Report · The approach skill's report is not shown

Status: open
Seen in: 9a970d79, 2338aae5 (2 sessions), first time
What happened: sv-tdd ended with no report, and sv-build step 4 counted as done. The step 7 card later gave the same criterion-to-test list, so the user lost nothing.
Evidence: 9a970d79:694: "The build is done, and a fresh subagent is now running `sv-verify` on the diff."; 2338aae5:600-607: the Refactor commit, then verify starts with no report.
Fix: cut a no-op: make the sv-tdd report the criterion · test list, and change the sv-build step 4 completion to "you have the criterion · test list for the card".

### F11 · sv-diagnose · step 1 · A missing setup stops the run and drops the bug

Status: open
Seen in: 92edf03f, d13fd348 (2 sessions), first time
What happened: In 92edf03f the skill stopped, and the user had to run setup and then send the screenshot again. In d13fd348 the user overrode the stop in advance. The fallback to `CLAUDE.md` and `docs/agents/issue-tracker.md` then worked through sv-diagnose and sv-ship.
Evidence: 92edf03f:61: "then run `/sv-diagnose` again with the screenshot. I stopped at step 1"; d13fd348:8: "even if we don't have the skills setup here, just go ahead and run the process."
Fix: sharpen wording: in step 1 of sv-diagnose and sv-ship, write "When the user says to go on without the setup, use `AGENTS.md` or `CLAUDE.md` and the tracker file in `docs/agents/`, and name the fallback in the report. When you stop, put the symptom and the path of each attachment in the stop message." Project part: KNOT has not run /sv-setup-skills.

### F12 · sv-review · step 3, and sv-build · step 6 · No rule for a check that fails because of the test environment

Status: open
Seen in: e03bd75e, 46161423 (2 sessions), first time
What happened: Suites failed for causes outside the branch: rows left in the test database, the leaked secret, and a test that fails under load. sv-review says to stop on a failure. The agent fixed the environment and reran. In 46161423 it called the checks done from reruns of the failed files only. Both reported it openly, but neither skill gives the rule.
Evidence: e03bd75e:270: "I empty that database, which only the tests use, and rerun."; e03bd75e:375: "That predates this spec. I rerun with it blanked"; 46161423:1893: "With the two reruns, every backend test has passed once without interference."
Fix: sharpen wording: in both steps, write "A failure in code on the branch is a hard finding. A failure that comes from the test environment, such as database state or an env var, may be fixed in the test environment only. Rerun, and name the cause, the failed test and the rerun on its own line of the card." Add an Excuses row: "It predates the spec" / "Name the cause. Do not hide it."

### F13 · sv-diagnose · step 10 · The card is not printed before the Approve question

Status: open
Seen in: d13fd348, first time
What happened: The agent asked Approve, Change or Run ui-check with no card in the chat. The user approved without the cause, the fix or the judgment calls. One judgment call said that the fix leaves part of the issue undone. The final report then pointed to "the card" that the user never saw.
Evidence: d13fd348:495: "Deleting the throwaway harnesses now, then the card."; d13fd348:509: AskUserQuestion "How do you want to proceed with the #558 fix?" with no text before it; d13fd348:491: "The diff still drops the 422 `detail`"; d13fd348:528: "The \"Check yourself\" steps on the card cover that."
Fix: sharpen wording: in step 10, write "Print the card as chat text before the question tool call. The question does not carry the card." Add to the completion: "the card text is in the chat above the question." Add an Excuses row: "The options describe the fix" / "The user approves the card. Print it first." Check sv-build step 7 and sv-review for the same gap.

### F14 · sv-build · step 5, and sv-tdd · step 3 · Verify starts while the build's checks still run

Status: open
Seen in: 46161423, first time
What happened: The agent sent the TDD report and started verify while the full backend suite still ran in the background. Two pytest runs then shared one test database and stuck for 43 minutes. The user approved a kill. The agent then told later verify runs to skip backend tests, which goes against sv-verify step 2.
Evidence: 46161423:1304: "The backend suite will report when done. Meanwhile I start the `sv-verify` run"; 46161423:1625: "Two pytest runs share the ticket test database and are stuck ... 43 min"; 46161423:1677: "Do NOT run any backend pytest"
Fix: sharpen wording: change the sv-tdd step 3 completion to "the full suite passes, and each run has finished. A run in the background counts only when its result is in." In sv-build step 5, write "Start verify only when each check run has finished. Do not tell sv-verify to skip a check."

### F15 · sv-diagnose · step 2, and sv-cleanup · step 4 · The worktree is made and removed by hand

Status: open
Seen in: d13fd348, first time
What happened: The agent used the conventions of the repo's own /knot-implement instead of sv-worktree. It entered the worktree with `cd`, not EnterWorktree, so the session had no guard. It removed the worktree with a chain, and the test database stayed.
Evidence: d13fd348:35: "I'll follow `docs/agents/issue-tracker.md` and the `/knot-implement` worktree conventions."; d13fd348:216: "cd /Users/santivqz/.../fix-558-seating-stale-party && ..."; d13fd348:715: "The worktree's test database is still in the main container."
Fix: add an Excuses row to sv-diagnose and sv-cleanup: "The setup is missing, so I make the worktree by hand" / "Call sv-worktree. It reports blocked when the repo is not ready." Project part: KNOT's `scripts/provision.sh` has no `drop` mode.

### F16 · sv-build · step 5 · A criterion that asks for sv-ui-check becomes a hard finding that no step closes

Status: open
Seen in: 2338aae5, first time
What happened: Criterion 7 asked for an sv-ui-check run, and the user did not pass `--ui`. Verify reported the missing check as hard. The agent went on with the hard finding open, then ran sv-ui-check before the card. The result was right, but it went outside steps 5 and 7.
Evidence: 2338aae5:639: "There is no sv-ui-check evidence yet"; 2338aae5:648: "No code change fixes it; `sv-ui-check` does"
Fix: add a step: in step 1, when a criterion names sv-ui-check or a browser check, treat the run as `--ui`. In step 5, a hard finding that only sv-ui-check can close goes to step 7.

### F17 · sv-build · step 5 · A hard finding is fixed a second time and not stopped

Status: open
Seen in: 46161423, first time
What happened: The second verify still found the forbidden word, in one test name. Step 5 says to stop. The agent fixed it and ran a third verify. The first fix missed the name because its grep used a short list of patterns.
Evidence: 46161423:1366: "grep -rn \"RemisionesDeParte\|otraParte\|...\""; 46161423:1700: "Real miss: one test name still says \"parte\". Fixing it."
Fix: sharpen wording: after a fix for a word or a name, grep `git diff <spec-branch>...HEAD` for each form of it before the re-verify. Then decide one rule: stop, or allow one more round for the same finding. Write that rule in step 5.

### F18 · sv-tdd · step 2 · Work that no criterion covers is built with no test and no name

Status: open
Seen in: 9a970d79, first time
What happened: The ticket asked for the variant C layout, but no criterion covered it. The agent built it in one untested commit and also changed the price bar and the page width. Nobody asked for those changes, and verify flagged them.
Evidence: 9a970d79:652: commit "Lay the caja form out in one narrow column"; 9a970d79:705: "The sticky price bar lost `lg:hidden`"
Fix: add a step: when the ticket asks for work that no criterion covers, name it before the loop. Build it after the last cycle as `Build: <what>`, change nothing outside it, and list it in the report.

### F19 · sv-tdd · step 2 · The test changes a literal from the spec with no question

Status: open
Seen in: 8b1d0077, first time
What happened: The spec gives the label "Pieza suajada 160 × 120 mm". The agent wrote the test and the code with the material added. The user learned about it only from the card.
Evidence: 8b1d0077:38: "the label reads \"Pieza suajada 160 × 120 mm\""; 8b1d0077:970: "The label of a pieza drops the alto and keeps the material"
Fix: add a step: in Red, write "When the ticket or the spec gives a literal, the test uses that literal. When you think it is wrong, ask before the green." Add an Excuses row: "The rest of the code does it the other way" / "The spec is the contract. Ask."

### F20 · sv-tdd · step 2 · A "still works" criterion gets no cycle and no rule

Status: open
Seen in: 9a970d79, first time
What happened: Criterion 4 said that marks and overrides still work. The agent cited the existing tests and made no Green commit, so the step 2 completion was not met. This ticket had also moved the selectors of those tests.
Evidence: 9a970d79:549: "The marks and override tests already pass unchanged."
Fix: sharpen wording: "A criterion that keeps existing behavior gets no cycle when existing tests cover it. Name those tests in the report and run them after the last change. When this ticket changed them, say so."

### F21 · sv-tdd · step 2 · Undo of a deliberate break leaves a diff, and the typecheck runs too often

Status: open
Seen in: 2338aae5, first time
What happened: An Edit undo left a whitespace diff, and the agent restored the file with `git checkout`. Later breaks used `git checkout --` and were clean. The typecheck ran in cycles that changed only tests.
Evidence: 2338aae5:361: "Whitespace left over from the undo. Restore the file from the commit."
Fix: sharpen wording: "Break a committed file for one run, and undo the break with `git checkout -- <file>`." Run the typecheck in each cycle that changes source.

### F22 · sv-review · step 6, and sv-ui-check · step 1 · The flow and the result are not printed as lists

Status: open
Seen in: e03bd75e, 2338aae5 (2 sessions), first time
What happened: In 2338aae5, sv-ui-check never printed the flow before the run. In e03bd75e, sv-review gave prose for the stories and no ✓ or ✗ line for each story, and step 7 then stopped before the card.
Evidence: 2338aae5:1147: "Now running the flow.\n\nStep 1, the cliente page at 1280px."; e03bd75e:652: "Stories 1, 2, 3 and 5 hold"
Fix: sharpen wording: in sv-ui-check, make "print the flow as a numbered list" the first action of step 2. In sv-review step 6, print the Verified list with one line for each story before step 7.

### F23 · sv-diagnose · step 8 · Step 8 deletes the harness and then runs the loop again

Status: open
Seen in: d13fd348, first time
What happened: The loop was a throwaway replay script. Step 8 says to delete the harnesses and then to run the loop again, which cannot both happen. Step 11 asks for the loop command, but the issue comment could only describe a deleted script.
Evidence: d13fd348:496: "rm .../replay_save.py ..."; d13fd348:523: "A replay script sent the stored plan through `save_seating_plan`"
Fix: sharpen wording: "Run the loop one more time. Then delete each harness that the regression test replaces. When the loop is a harness, keep it outside the repo until step 11, and put its text, redacted, in the issue comment."

### F24 · sv-diagnose · steps 1 to 3 · The order fits a ticket, not a screenshot

Status: open
Seen in: d13fd348, first time
What happened: The agent made the loop and saw it fail before it filed the issue, so the issue had the exact symptom. That was better than the skill order. The agent also read history and logic away from the symptom path before the loop existed.
Evidence: d13fd348:139: "RED: 422 The party for Jose Eugenio Puente does not fit at that table"; d13fd348:161: "gh issue create --label bug"; d13fd348:89: "Inspect recent guest commits and frontend party size logic"
Fix: sharpen wording: for an input that is a screenshot, a Sentry link or an error, do step 1 after step 4, and step 2 before step 7. Steps 3 to 6 change no repo file. Before the loop exists, read only the code that the loop calls.

### F25 · sv-cleanup · step 7 · The migration check uses a guessed folder

Status: open
Seen in: d13fd348, first time
What happened: The agent grepped for `alembic/versions`. KNOT keeps its migrations in `backend/migrations/versions`, so the check could find nothing.
Evidence: d13fd348:717: "grep -i alembic/versions"; d13fd348:730: "**Migrations:** none came in with this pull."
Fix: sharpen wording: "Find the migration folder from `AGENTS.md` or from `script_location` in `alembic.ini`."

### F26 · sv-cleanup · new step · Servers and background tasks of the branch are not stopped

Status: open
Seen in: d13fd348, first time
What happened: The agent checked only the ports and said that the session started no dev server. A background dev server task still ran from before a /clear, and the worktree was removed under it.
Evidence: d13fd348:850: "This session never started one"; d13fd348:880: "So I was wrong earlier"
Fix: add a step before the worktree step: "Stop each dev server and background task that runs from the worktree. Check the background tasks and the processes whose working directory is in the worktree."

### F27 · sv-setup-skills · steps 1 and 2 · The summary is skipped, and two choices go in one question call

Status: open
Seen in: 92edf03f, first time
What happened: The agent explored for about eight calls with no message, and the harness sent a nudge. It sent no summary. Then it asked two choices in one call. The user rejected the call and interrupted, with no reason given.
Evidence: 92edf03f:116: "The user hasn't heard from you in a while"; 92edf03f:120: one AskUserQuestion with "Provision" and "domain.md"; 92edf03f:125: "[Request interrupted by user for tool use]"
Fix: sharpen wording: "At the end of step 1, send one line that names the tracker and each conflict. Send the summary message, then ask each choice in its own question call." Add an Excuses row: "The choices are related, so I batch them" / "One question for each call."

### F28 · sv-setup-skills · step 1 · No path for the repo's own provision.sh or for files of another skill set

Status: open
Seen in: 92edf03f, first time
What happened: KNOT has its own `scripts/provision.sh`, which an ADR requires. PROVISIONING.md assumes the template. The agent spent about seven reads on the clash. The repo also had tracker docs and labels from another skill set, and step 1 looks only for files of an earlier sv run.
Evidence: 92edf03f:120: "the Knot script follows ADR 0012, and the sv template conflicts with it"; 92edf03f:39: "domain.md issue-tracker.md knowledge-base.md triage-labels.md"
Fix: add a step: in PROVISIONING.md, add an "Existing script" section. Keep a script with no ENGINE header, check the contract that sv-worktree needs (no argument provisions, `drop` removes), and add only the missing mode. In step 1, read `docs/adr/` and each file in `docs/agents/`. In step 2, ask for each overlapping file whether to merge it, keep both or delete it.

### F29 · sv-build · step 7 · "Taking that as Approve." after a click on Approve

Status: open
Seen in: 46161423, first time
What happened: The user picked the Approve option, and the agent still used the phrase meant for free text.
Evidence: 46161423:1908: "Taking that as Approve."
Fix: sharpen wording: in sv-build step 7, sv-review and sv-diagnose, write "Only when the answer is free text, start the reply with 'Taking that as Approve.'"

### F30 · project · shell and tracker · zsh globs and the sub-issues command

Status: open
Seen in: 92edf03f, 9a970d79, 2338aae5, 8b1d0077 (4 sessions), first time
What happened: zsh `nomatch` failed unquoted `--include=*.md` and `[id]` paths. vvfapp's tracker.md gives `gh issue view --json subIssues`, which failed with its jq filter.
Evidence: 92edf03f:49: "no matches found: --include=*.md"; 2338aae5:147: "no matches found: frontend/src/routes/clientes/[id]/+page.server.ts"; 8b1d0077:223: "expected an object but got: array"
Fix: project. F1 covers path quoting in the skills. tracker.md needs the `gh api repos/<owner>/<repo>/issues/<spec>/sub_issues` form.

### F31 · project · outside skills · /knot-release and /knot-cleanup

Status: open
Seen in: d13fd348, first time
What happened: /knot-release opened the develop-to-main PR, repaired the ancestry of main and listed the legs that rebuild. The sv set has no release step, and the sv-cleanup report named /knot-release as next. /knot-cleanup ran after /sv-cleanup and found nothing to do, except `git worktree prune`.
Evidence: d13fd348:825: "The release PR is open ... Merging it is the deploy"; d13fd348:898: "I already ran most of this teardown with `/sv-cleanup`."
Fix: project. Keep /knot-release in KNOT. Retire /knot-cleanup when KNOT moves to the sv set. Optional: add `git worktree prune` to sv-worktree Remove.

## Worked

- sv-build step 1: each run read tracker.md, the ticket, its blockers and the parent spec, then set in-progress and the assignee before the build.
- sv-worktree Make and Remove: each ticket linked `branch.<ticket>.spec`, entered with EnterWorktree, and took the databases from the hook output. Each teardown ran `provision.sh drop`, ExitWorktree keep, worktree remove, branch -D and `git worktree list`.
- sv-tdd step 2: each red was checked for the right reason. Each test that passed on its first run got a deliberate break, a red, an undo and a note in the commit.
- sv-build steps 5 and 7: verify always ran in a fresh subagent, and every judgment call reached the card and the closing comment.
- sv-build step 6: each run compared the local and remote spec heads before the rebase.
- sv-diagnose steps 3 to 5: a deterministic replay went red with the exact symptom, and three ranked hypotheses each had a prediction.
- sv-review step 3: the agent checked the `_test` suffix before it emptied a database.
- sv-review step 7: one question for each gap, with a recommended option, then one follow-up ticket with `--parent`.
- sv-ui-check step 2: it fell back to DevTools when the extension was not connected, and it asked the user to sign in and typed no password.
- sv-pr: the body followed the template, with a call-tree diff, Before and After, and Merge Danger.
