# DevTools

Read this file when the Claude in Chrome extension is not connected and `sv-ui-check` drives the Chrome DevTools tools.

## Start

Each session runs its own DevTools server with `--isolated`, so its Chrome has a fresh profile that no other session shares. The browser starts signed out: step 2 of `sv-ui-check` covers the sign-in.

When a tool answers "The browser is already running", the server is not isolated, and another session owns that Chrome. Leave that Chrome alone, because the other session's check runs in it. Ask one question with the question tool: "Connect the extension" or "Skip the browser check". Tell the user to start the server with `--isolated`, as the Install section of the README says.

## Steps

The DevTools tools have no batch. A step that clicks starts with one `take_snapshot` to get the uids, the same as `find` before a batch.

- Change the page only with `click`, `fill` and `fill_form`, so that the app's handlers run. Use `fill_form` for a step with more than one field.
- Use `evaluate_script` only to read. End each step with one `evaluate_script` read.
- Open the first page of the flow with `navigate_page`. Reach every other page through its links, or through a URL that a link on the page shows.
- Set a screen width with `emulate` and its viewport. Read `window.innerWidth`, and report the width that the page shows.
- Send the next call only after `navigate_page` returns.
- Call `take_screenshot` and `take_snapshot` with no file path. The tools refuse a path outside the workspace roots.

## Close

Close each page that you opened with `close_page`. DevTools cannot close the last open page: navigate it to `about:blank`. The isolated Chrome closes with the session.
