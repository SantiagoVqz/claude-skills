---
name: sv-ui-check
description: "Drive the app in a browser to check a change, then give the user a short list of what passed and what to check by hand. Use when the user runs /sv-ui-check, /sv-build checks a ticket in a browser, or /sv-review walks the stories."
argument-hint: "[ticket | what to check]"
---

# UI check

`/sv-ui-check` runs the app, does the main flow of a change in a browser, and reports. It changes no code. The user decides when it runs, or `/sv-build` runs it for a ticket whose criteria show in a browser. The server and the tab stay open until the user answers, so the user can look for themselves.

## 1. Pick the flow

Read the target: the ticket and its acceptance criteria, or the text the user gave. With no argument, use the ticket of the current `ticket/<n>-` branch.

Write the flow as a short list of steps, the way a user does the feature from start to end. Cover the acceptance criteria that a browser can show. A criterion that a browser cannot show stays out. A screen width, such as 390px, is a parameter of a step, not a new step.

When `/sv-review` calls you, it gives the flow: one step for each user story, with no limit on the count.

Completion: you have the flow, five steps or fewer, or the flow from `/sv-review`.

## 2. Run

Print the flow as a numbered list in your message. Do this first, before any other call.

Read the run section of the README or `AGENTS.md`, and start each service that the pages need first, such as the database or the API. Then start the dev server in the current worktree, in the background, with no fixed port. Read the URL from the server's ready line.

Check that the dev database holds the rows that the flow needs. Read the database name and the user from the database URL in the worktree's env file. When rows are missing and the database is a worktree fork, with a branch suffix such as `<app>_<branch>`, make the fewest rows that the flow needs. Use the project's seed script or the API, and ask no question, because the fork is disposable. For any other database, ask the user first. The report names the rows that you made.

Load the Claude in Chrome tools and `browser_batch` in one ToolSearch call, and open a new tab. When the extension is not connected, use the Chrome DevTools tools, and read [DEVTOOLS.md](DEVTOOLS.md) first.

Do each step of the flow in one `browser_batch` call. When a step needs a ref, do one `find` call first, then the batch. End each batch with a read of the page, and compare it with what the step expects. Before you mark a step ✗, read the URL and the console.

When the app goes to a sign-in page, ask the user to sign in in that window, and wait. Type no password yourself. Then do the step again.

Completion: the flow is in the chat as a numbered list, and each step passed or failed. The dev server and the tab stay open.

## 3. Report

Print the two lists in your message, one line each, also when a caller ran you. When a caller such as `/sv-build` ran you, stop here: the caller asks the question and stops the server. When the user ran you, or you started yourself with no caller skill, ask with the question tool: "Approve" or "Change".

```markdown
Verified:
- ✓ <step> · <what you saw>
- ✗ <step> · <what you saw instead>

Data: <the rows that you made, or "none">

Check yourself at <URL>:
1. <what to do> · <what the user sees>
```

"Check yourself" has three steps or fewer: what a browser check cannot judge, such as the look and the feel.

Completion: the lists are in the chat. When the user ran you, they answered, and you stopped the dev server and closed the tab.
