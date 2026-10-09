---
name: ui-review
description: Browser-driven UI review. Walk the screens a change touches in Chrome against its spec and a fixed rubric, report a punch list, then fix and verify the items the user picks. Use when the user asks for a UI review, wants a branch's UI changes checked in the browser, or wants to see a change working in the real app.
argument-hint: "[fixed-point] [route]"
---

# ui-review, the browser-driven review

You drive the review. A subagent walks every screen the change touches and returns a **punch list**: defects, each with evidence. The user picks items from the list. You fix each picked item and verify it in the browser. The user can also drive the Chrome window, and their feedback goes onto the same punch list.

The skill ends at verified fixes in the working tree. Commits, PRs and shipping belong to other skills.

**Prereqs.** The Chrome DevTools MCP is connected: open a page, DOM snapshot, console and network logs, navigate, click, type, evaluate script, resize, emulate, Lighthouse, screenshot. If Chrome comes up headless (no display, a remote session), the user cannot drive. Say so up front. The walk still runs, with screenshot-to-file evidence (`take_screenshot` with `filePath`).

## 1. Find how the app runs

Read before launching, in this order, and stop at the first source that answers:

1. A project skill, or the `CLAUDE.md` / `AGENTS.md` / `README.md` section that names the dev command and port.
2. `package.json` scripts (`dev`, `start`), `Makefile`, `Procfile`, `docker-compose.yml`, `pyproject.toml` entry points.
3. `.env` and framework config for the port and the API base URL the frontend expects.

Name every process the page needs (frontend, API, workers) with its command, directory, and port. If a required piece stays unknown (which port, which env file, how to log in), ask the user once with the options you found. A guessed command is worse than one question.

## 2. Setup

1. **Ports.** `lsof -nP -iTCP:<PORT> -sTCP:LISTEN` per server. If the right app already serves from the right directory (`lsof -a -p <pid> -d cwd`), reuse it. Otherwise launch each as a background task from its own directory, so a crash re-invokes you.
2. **Clean boot.** Read each background task's output until its ready line (Vite `Local:`, uvicorn `Application startup complete`, Next `Ready`, or whatever the framework prints). Surface boot errors and stop rather than continuing.
3. **Wait until the frontend answers.** The ready line arrives before the first request can be served, and navigating during the cold start times out.
   ```bash
   until curl -sf -o /dev/null http://localhost:<PORT>/; do sleep 2; done   # cap at 120 s
   ```
4. **Open Chrome** at `http://localhost:<PORT><route>` (the route argument, default `/`). If the app needs a login, ask the user to sign in in the driven window, then confirm the page rendered with `take_snapshot`.
5. **Baseline scan.** `list_console_messages` (error, warn) and `list_network_requests` (4xx, 5xx). Ask the user about anything you cannot classify as benign. Keep a **benign-noise list**, so later scans skip that noise.

## 3. Build the review plan

1. **Pin the fixed point.** Use the fixed-point argument. Without one, use the merge-base with the trunk. Take the diff against the working tree, so uncommitted work is in scope: `git diff $(git merge-base <fixed-point> HEAD)`.
2. **Find the spec.** Look in this order: issue references in the commit messages (fetch them through `docs/agents/issue-tracker.md`), then a spec file under `docs/`, `specs/` or `.scratch/` that matches the branch. Copy the acceptance criteria verbatim. With no spec, the walk runs the rubric only, and the report says so.
3. **Map the diff to screens.** For each changed UI file, follow its importers up to the route or page files that render it. A changed style, token or shared component reaches every route that uses it. Take a sample of those routes and name the sample in the plan.
4. **Write the rows.** One row is one route, one state (populated, empty, error, loading) and one interaction (the flow the change affects, or "view"). Note the criteria each row covers. Every acceptance criterion maps to at least one row. A criterion with no screen to check goes on a "not browser-checkable" line.
5. **Apply the route argument.** A route argument keeps only the rows on that route. With a route and an empty diff, the plan is that route in its default state.

If the diff touches no UI file and no route was given, tell the user and ask for a route. Show the plan as a short table, then start the walk without waiting.

## 4. Walk the plan

Dispatch one subagent for the walk. It keeps screenshots out of your context, and it keeps the fix loop out of the walker's sight. Wait for its result. The browser is shared, so leave the page alone while the walk runs. If you cannot dispatch a subagent, walk inline with the same prompt.

Give the subagent this prompt, with the placeholders filled:

> You walk a UI review plan in Chrome through the DevTools MCP. The app runs at `<base URL>`, and the user is signed in. Read `<skill dir>/references/rubric.md` and apply every check to every row. Read `<skill dir>/references/screenshot-budget.md` before your first screenshot. Read the Gotchas section of `<skill dir>/SKILL.md`. Save every screenshot with `filePath` under `<scratch dir>`.
>
> Plan: `<rows>`. Acceptance criteria: `<criteria, verbatim>`. Benign noise, which you ignore: `<list>`.
>
> Reach each row's state through the app: its data, a query parameter, a fixture or a flow. If you cannot reach a state, mark the row blocked and give the reason. Edit no code. Read code only to name the file a defect most likely lives in.
>
> You are done when every row has a verdict (pass, fail, or blocked) and every rubric check on every row has a result. A check that does not apply needs a one-line reason. Return a coverage table (row, verdict) and the punch list. Each punch item has: an ID (P1, P2, ...), the row, the failed check or criterion, the evidence (the assertion and its result, or a screenshot path), and the suspected file.

## 5. Report the punch list

Report the coverage counts (pass, fail, blocked), the blocked reasons, the punch list, and the "not browser-checkable" criteria. Then stop. The user picks the items to fix. They can also drive the window and give feedback.

## 6. Fix loop

Each picked punch item and each piece of user feedback goes through this loop. Feedback arrives as a structured "Page Feedback" block (file:line, classes, component tree) or freeform. Add feedback to the punch list as the next ID.

1. **Inspect the exact screen.** Console, network (filter fetch/xhr, find the failing call with its status and body), `take_snapshot`, and `evaluate_script` for precise reads. Also read the server logs for the matching error (a 500 traceback, an HMR or import error).
2. **Diagnose the root cause first.** Read the real code. If the user reported a problem without asking for a fix, give a short diagnosis and wait. A picked punch item counts as a request for a fix. One fix per diagnosis, no stacked guesses.
3. **Fix exactly what the item names.** Follow the repo's conventions. Adjacent restyling, redesigns and new UI elements are suggestions: offer them, and touch them only after an explicit yes.
4. **Verify in the browser.** Reload or navigate, re-check console (no new errors) and network (the call now 200), then prove the fix with an `evaluate_script` assertion: computed styles, class membership, element order, counts. Re-run the rubric check that failed, on the same row.

An item is done when its assertion passes and the benign-noise list has not grown. The review is done when every picked item is done and a final baseline scan on each fixed route is clean.

## 7. Screenshot budget

A page screenshot costs about 60 times an accessibility snapshot, and every later step re-reads it. Read `references/screenshot-budget.md` before the first screenshot of a session.

## 8. Gotchas

- **Snapshot `uid`s reset on every navigation or reload.** Take a fresh `take_snapshot` before referencing one, or the interaction fails with "not found / detached".
- **Portals hide options.** Select, dropdown, and context-menu items often render in a portal that is absent from the accessibility tree. Open the trigger, then drive with keys (ArrowDown ×N, Enter). Right-click menus need a `contextmenu` `MouseEvent` dispatched through `evaluate_script`.
- **Async navigation can report an intermediate URL.** Confirm the final state with `list_pages` or `evaluate_script`.
- **A referenced but undefined CSS utility silently no-ops** (a Tailwind `@utility`, a plugin class). If a style "won't apply", grep that the utility exists.
- **Server reload after an edit.** Check that the backend log shows a clean restart and the frontend log shows the HMR update with no error before you re-test.
- **`emulate` settings persist across navigations.** After an emulated check, reset the viewport to 1280 and `colorScheme` to `"auto"`, or the next row runs at the wrong size or theme.

## 9. Teardown

When the review is done, or the session wraps, stop the servers this skill started (kill the background tasks) and `close_page` the tab. Leave servers that were already running before this skill. If a task kill does not take, kill by port:

```bash
lsof -tiTCP:<PORT> -sTCP:LISTEN | xargs kill 2>/dev/null
```
