---
name: ui-review
description: Browser-driven UI review loop. Start or reuse the project's dev servers, open the app in Chrome through the DevTools MCP, baseline-scan console and network, then work an inspect, diagnose, fix, verify-in-browser loop on the user's feedback. Use when the user says "ui review", "review the ui", "test it in the browser", or wants to see a UI change working in the real app.
argument-hint: [route]
---

# ui-review, the browser-driven review loop

Bring the local app up under Chrome DevTools and work a tight loop. The user drives the Chrome window. On each piece of feedback you inspect that exact screen (console, network, DOM) and the server logs, diagnose the root cause, fix in code, and verify the fix back in the browser.

This skill starts the servers and runs the review. It does not commit, open PRs, or ship.

**Prereqs.** The Chrome DevTools MCP is connected: open a page, DOM snapshot, console and network logs, navigate, click, type, evaluate script, screenshot. If Chrome comes up headless (no display, a remote session), the user cannot drive: say so up front and switch to screenshot-to-file verification (`take_screenshot` with `filePath`).

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
4. **Open Chrome** at `http://localhost:<PORT><route>` (the argument, default `/`). If the app needs a login, ask the user to sign in in the driven window, then confirm the page rendered with `take_snapshot`.
5. **Baseline scan.** `list_console_messages` (error, warn) and `list_network_requests` (4xx, 5xx). Ask the user about anything you cannot classify as benign, and keep a list of the benign noise so later scans skip it. Report the baseline, then hand off: "You drive. Navigate and tell me when to inspect."

## 3. Review loop (per feedback)

Feedback arrives as a structured "Page Feedback" block (file:line, classes, component tree) or freeform. For each:

1. **Inspect the exact screen.** Console, network (filter fetch/xhr, find the failing call with its status and body), `take_snapshot`, and `evaluate_script` for precise reads. Also read the server logs for the matching error (a 500 traceback, an HMR or import error).
2. **Diagnose the root cause first.** Read the real code. If the user reported a problem without asking for a fix, give a short diagnosis and wait. If they asked for a fix, diagnose, then proceed. One fix per diagnosis, no stacked guesses.
3. **Fix exactly what the feedback names.** Follow the repo's conventions. Adjacent restyling, redesigns, and new UI elements are suggestions: offer them, and touch them only after an explicit yes.
4. **Verify in-browser.** Reload or navigate, re-check console (no new errors) and network (the call now 200), `take_snapshot`, and `evaluate_script` for exact assertions (computed styles, class membership, element order, counts). A script assertion beats eyeballing a screenshot for any style or DOM claim.

A feedback item is done when its assertion passes and the benign-noise list has not grown.

## 4. Screenshot budget

Screenshots dominate the loop's context cost: a page shot runs about 60x an accessibility snapshot, and every later step re-reads it. Assert with `take_snapshot` and `evaluate_script` where you can, take shots late (verification, not exploration), and use `filePath`, JPEG, and `uid` or `fullPage` scoping deliberately. If an image is the only way to judge it, take the image. Rules and rationale: `references/screenshot-budget.md`, read it before the first screenshot of a session.

## 5. Gotchas

- **Snapshot `uid`s reset on every navigation or reload.** Take a fresh `take_snapshot` before referencing one, or the interaction fails with "not found / detached".
- **Portals hide options.** Select, dropdown, and context-menu items often render in a portal that is absent from the accessibility tree. Open the trigger, then drive with keys (ArrowDown ×N, Enter). Right-click menus need a `contextmenu` `MouseEvent` dispatched through `evaluate_script`.
- **Async navigation can report an intermediate URL.** Confirm the final state with `list_pages` or `evaluate_script`.
- **`evaluate_script` is the precision tool.** `getComputedStyle`, `classList`, element order, and counts prove a fix.
- **A referenced but undefined CSS utility silently no-ops** (a Tailwind `@utility`, a plugin class). If a style "won't apply", grep that the utility exists.
- **Server reload after an edit.** Check that the backend log shows a clean restart and the frontend log shows the HMR update with no error before you re-test.

## 6. Teardown

When the loop is over (the user confirms done, or the session wraps), stop the servers this skill started (kill the background tasks) and `close_page` the tab. Leave servers that were already running before this skill. If a task kill does not take, kill by port:

```bash
lsof -tiTCP:<PORT> -sTCP:LISTEN | xargs kill 2>/dev/null
```
