# UI Prototype

Generate **several radically different UI variations** in one artifact, switchable from a floating bottom bar. The user flips between variants at the artifact link, picks one (or steals bits from each), then throws the rest away.

If the question is about logic/state rather than what something looks like, this is the wrong branch. Use [LOGIC.md](LOGIC.md).

## When this is the right shape

- "What should this page look like?"
- "I want to see a few options for this dashboard before committing."
- "Try a different layout for the settings screen."
- Any time the user would otherwise spend a day picking between three vague mockups in their head.

## Judge variants in context

A UI prototype is much easier to judge when it's **butting up against the rest of the app**: real header, real sidebar, real data, real density. A variant on a blank page is a vacuum: every variant looks fine in isolation.

- **Host page.** When the variants belong inside an existing page, or would naturally live inside one (a new section of the dashboard, a new card on the settings screen, a new step in an existing flow), read that page's code and rebuild its chrome (header, sidebar, neighbouring sections) around each variant. Use a bare page only when the thing has no plausible home in the app.
- **Styling.** Build to the fidelity bar in the [SKILL](SKILL.md), so each variant passes for a shipped screen. When the project's design system is synced to claude.ai/design, build with it.
- **Content.** Fill every variant with realistic sample data at the real page's density, since an empty artifact flatters every layout.

## Process

### 1. State the question and pick N

Default to **3 variants**. More than 5 stops being radically different and starts being noise, so cap there.

Write the plan in one line at the top of the artifact:

> "Three variants of the settings page, inside the existing settings chrome."

This works whether the user is here to push back or not.

### 2. Generate radically different variants

Draft each variant. Hold each one to:

- The page's purpose and the data it has access to.
- The project's styling, as [Judge variants in context](#judge-variants-in-context) describes.
- A clear name, e.g. `A (Sidebar layout)`, `B (Single column)`.

Variants must be **structurally different**: different layout, different information hierarchy, different primary affordance, not just different colours. Three slightly-tweaked card grids isn't a UI prototype, it's wallpaper. If two drafts come out too similar, redo one with explicit "do not use a card grid" guidance.

### 3. Build the floating switcher

A small fixed-position bar at the bottom-centre of the screen with three pieces:

- **Left arrow**: cycles to the previous variant (wraps around).
- **Variant label**: shows the current variant key and name, e.g. `B (Sidebar layout)`.
- **Right arrow**: cycles forward (wraps around).

Behaviour:

- Hold the current variant in component state, since the artifact has no route to carry it.
- Keyboard: `←` and `→` arrow keys also cycle. Leave arrow keys alone when an `<input>`, `<textarea>`, or `[contenteditable]` is focused.
- Visually distinct from the page (e.g. high-contrast pill, subtle shadow) so it's obviously not part of the design being evaluated.

### 4. Hand it over and iterate

Publish the artifact and send the link with the variant names. The user will flip through whenever they get to it. The interesting feedback is usually **"I want the header from B with the sidebar from C"**, which is the actual design they want. Add it as a new variant in the same artifact, and republish to the same link.

### 5. Capture the answer

Once a variant has won, capture the answer (which variant and why) the way the [SKILL](SKILL.md) describes. The winner enters the codebase as a rewrite in the project's own components.

## Anti-patterns

- **Variants that differ only in colour or copy.** That's a tweak, not a prototype. Real variants disagree about structure.
- **Sharing too much code between variants.** A shared `<Header>` is fine; a shared `<Layout>` defeats the point. Each variant should be free to throw out the layout.
- **Wiring variants to real mutations.** Read-only prototypes are fine. If a variant needs to mutate, point it at an in-memory stub: the question is "what should this look like", not "does the backend work".
- **Wireframe-grade variants.** Grey boxes, placeholder text and default browser styles hide the real differences. Each variant uses the project's real look.
- **Promoting the prototype directly to production.** The variant code was written under prototype constraints (no tests, minimal error handling). Rewrite it properly when you fold it in.
