# UI review rubric

Apply every check to every row of the plan. A check that does not apply to a row gets a one-line reason, for example "no form on this row" for the keyboard check. A failed check becomes a punch item with its evidence.

Prefer an assertion to a screenshot. A check that ends in a judgement call (layout, contrast) takes one screenshot, saved with `filePath`.

## 1. Console and network

- `list_console_messages` for errors and warnings. Fail on any entry that is not on the benign-noise list.
- `list_network_requests`, filtered to fetch and xhr. Fail on any 4xx or 5xx that is not on the benign-noise list. Record the URL, the status and the response body.

## 2. Acceptance criteria

For each criterion the row covers, write one assertion with `evaluate_script` or read it from `take_snapshot`. The evidence is the assertion and its result. A criterion that needs a human eye (copy tone, "looks right") gets a screenshot and the note "needs human judgement". It is not a fail.

## 3. Viewport overflow

Run the row at three viewports with `emulate`: `375x812x2,mobile,touch`, `768x1024x2,mobile,touch` and `1280x800x1`. At each one, run:

```js
() => {
  const d = document.documentElement;
  const wide = [...document.querySelectorAll('body *')]
    .filter(el => el.getBoundingClientRect().right > d.clientWidth + 1)
    .slice(0, 10)
    .map(el => el.tagName.toLowerCase() + (el.className ? '.' + String(el.className).split(' ')[0] : ''));
  return { pageOverflows: d.scrollWidth > d.clientWidth, wide };
}
```

Fail when `pageOverflows` is true. The `wide` list names the elements that cause it. Take one JPEG screenshot at 375 to judge the mobile layout: overlap, stacking, tap targets that touch.

## 4. Clipped text

```js
() => [...document.querySelectorAll('body *')]
  .filter(el => {
    if (el.children.length || !el.textContent.trim()) return false;
    const s = getComputedStyle(el);
    const clips = s.overflow !== 'visible' || s.overflowX !== 'visible';
    const over = el.scrollWidth > el.clientWidth + 1 || el.scrollHeight > el.clientHeight + 1;
    return clips && over && s.textOverflow !== 'ellipsis' && !s.webkitLineClamp?.match(/\d/);
  })
  .slice(0, 10)
  .map(el => el.textContent.trim().slice(0, 60))
```

Fail on each returned text. Text cut with an ellipsis or a line clamp is a design choice, so the script skips it. Run this check at 375 and at 1280.

## 5. Accessible names

- In `take_snapshot`, every button, link, textbox, combobox, checkbox and switch has a name. Fail on each one without a name.
- `document.querySelectorAll('img:not([alt])').length` is 0.
- Run `lighthouse_audit` with `mode: "snapshot"` once per route and state. Report each failed accessibility audit, contrast included. Pass `outputDirPath` under the scratch directory, so the report stays on disk.

## 6. Keyboard

Only for a row whose interaction has a form, a menu, a dialog or a button flow.

- Press Tab through the interactive elements with `press_key`. After each press, read the focused element and its focus style:
  ```js
  () => { const el = document.activeElement; const s = getComputedStyle(el);
    return { el: el.outerHTML.slice(0, 80), outline: s.outlineStyle + ' ' + s.outlineWidth, shadow: s.boxShadow }; }
  ```
- Fail when focus lands on an element with no visible focus style (no outline and no box shadow).
- Fail when the focus order skips an interactive element or jumps against the visual order.
- Fail when the flow cannot finish by keyboard alone. A dialog takes Escape to close and returns focus to its trigger.

## 7. Dark mode

Only when the app has a dark theme: a `prefers-color-scheme` rule, a `dark` class strategy or a theme toggle. Set `emulate` with `colorScheme: "dark"` (or use the toggle), then re-run checks 3 and 5 at 1280. Take one JPEG screenshot to judge unreadable text and hard-coded light surfaces. Reset with `colorScheme: "auto"`.

## Evidence

Each punch item carries one of:

- The assertion and its result, copied as returned.
- A screenshot path, with one line on what it shows.
- A Lighthouse audit ID, its failing element, and the report path.
