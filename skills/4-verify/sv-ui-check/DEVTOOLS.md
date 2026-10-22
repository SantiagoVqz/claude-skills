# DevTools

Read this file when the Claude in Chrome extension is not connected and `sv-ui-check` drives the Chrome DevTools tools.

## Start

When a tool answers "The browser is already running", a Chrome from another session holds the DevTools profile. Run `pgrep -fl chrome-devtools-mcp/chrome-profile`. Then ask one question with the question tool: "Kill <pid>", "Connect the extension" or "Skip the browser check". Ask it once, and act on the answer.

## Steps

The DevTools tools have no batch. A step that clicks starts with one `take_snapshot` to get the uids, the same as `find` before a batch.

- Change the page only with `click`, `fill` and `fill_form`, so that the app's handlers run. Use `fill_form` for a step with more than one field.
- Use `evaluate_script` only to read. End each step with one `evaluate_script` read.
- Reach a page through its links, from a page that you know.
- Send the next call only after `navigate_page` returns.
- Call `take_screenshot` and `take_snapshot` with no file path. The tools refuse a path outside the workspace roots.

## Close

DevTools cannot close the last open page. Navigate it to `about:blank` in place of a close.
