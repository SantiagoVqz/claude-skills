# Gotchas

Browser traps that cost a retry. They apply to the walk and to the fix loop.

- **Snapshot `uid`s reset on every navigation or reload.** Take a fresh `take_snapshot` before referencing one, or the interaction fails with "not found / detached".
- **Portals hide options.** Select, dropdown, and context-menu items often render in a portal that is absent from the accessibility tree. Open the trigger, then drive with keys (ArrowDown ×N, Enter). Right-click menus need a `contextmenu` `MouseEvent` dispatched through `evaluate_script`.
- **Async navigation can report an intermediate URL.** Confirm the final state with `list_pages` or `evaluate_script`.
- **A referenced but undefined CSS utility silently no-ops** (a Tailwind `@utility`, a plugin class). If a style "won't apply", grep that the utility exists.
- **Server reload after an edit.** Check that the backend log shows a clean restart and the frontend log shows the HMR update with no error before you re-test.
- **`emulate` settings persist across navigations.** After an emulated check, reset the viewport to 1280 and `colorScheme` to `"auto"`, or the next row runs at the wrong size or theme.
