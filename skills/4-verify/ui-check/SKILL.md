---
name: ui-check
description: "Drive the app in a browser to check a change, then give the user a short list of what passed and what to check by hand. Use when the user runs /ui-check, /build runs with --ui, or /review walks the stories."
argument-hint: "[ticket | what to check]"
---

# UI check

`/ui-check` runs the app, does the main flow of a change in a browser, and reports. It changes no code. The user decides when it runs, because each run starts a dev server. The server and the tab stay open until the user answers, so the user can look for themselves.

## 1. Pick the flow

Read the target: the ticket and its acceptance criteria, or the text the user gave. With no argument, use the ticket of the current `ticket/<n>-` branch.

Write the flow as a short list of steps, the way a user does the feature from start to end. Cover the acceptance criteria that a browser can show. A criterion that a browser cannot show stays out.

When `/review` calls you, it gives the flow: one step for each user story, with no limit on the count.

Completion: you have the flow, five steps or fewer, or the flow from `/review`.

## 2. Run

Start the dev server in the current worktree, in the background, with no fixed port. Read the URL from the server's ready line. Load the Claude in Chrome tools and `browser_batch` in one ToolSearch call, and open a new tab. When the extension is not connected, use the Chrome DevTools tools.

Do each step of the flow in one `browser_batch` call. When a step needs a ref, do one `find` call first, then the batch. End each batch with a read of the page, and compare it with what the step expects.

The DevTools tools have no batch. Use `fill_form` for a step with more than one field. End each step with one `evaluate_script` read, not a full snapshot.

Completion: each step passed or failed. The dev server and the tab stay open.

## 3. Report

Write two lists, one line each. When a caller such as `/build` ran you, stop here: the caller asks the question and stops the server. When the user ran you, ask with the question tool: "Approve" or "Change".

```markdown
Verified:
- ✓ <step> · <what you saw>
- ✗ <step> · <what you saw instead>

Check yourself at <URL>:
1. <what to do> · <what the user sees>
```

"Check yourself" has three steps or fewer: what a browser check cannot judge, such as the look and the feel.

Completion: the lists are shown. When the user ran you, they answered, and you stopped the dev server and closed the tab.

DevTools cannot close the last open page. Navigate it to `about:blank` in place of a close.
