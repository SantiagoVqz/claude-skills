# UI Prototype

Generate **several radically different UI variations** in one artifact, laid out side by side on one **canvas**, like frames in Figma. The user compares every variant at a glance at the artifact link, picks one (or steals bits from each), then throws the rest away.

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
- **Content.** Fill every variant with realistic sample data at the real page's density, since an empty artifact flatters every layout. Read the real counts from the dev database or the user's screenshots, and show the busiest realistic case, such as the busiest day.
- **Served data.** Show only the data and the actions that the backend serves. Label each one that it does not serve yet as "Not served yet" on the frame.

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

Keep each variant **simple**:

- Make one variant the simplest layout that does the user's main task.
- Use one control pattern per form. Use a search field for a long list, such as opponents or groups.
- Show at rest only what the user needs to decide. The rest opens on demand.
- Make each variant a new structure for this task. A copy of an existing screen, such as the app's calendar, is not a variant.

### 3. Lay out the canvas

When the Artifact quickstart offers the Design type, build on it, and follow its instructions: each variant is one artboard. Otherwise build one page with the frames in a row that scrolls sideways.

- Size each frame to the target device, such as a 390px phone or a 1280px desktop.
- Put a label above each frame with its key and name, e.g. `B (Sidebar layout)`.
- When a variant has several screens, give it one row of frames in flow order, and stack the variant rows.
- Every frame shows at once, so the user compares variants side by side.

### 4. Hand it over and iterate

Check each frame as the [SKILL](SKILL.md) says, before the handover. Look for clipped text, duplicate labels, tap targets under 44px, and the empty, loading and error states.

Publish the artifact and send the link with the variant names. The user looks across the frames whenever they get to it. The interesting feedback is usually **"I want the header from B with the sidebar from C"**, which is the actual design they want. Add each iteration as a new frame next to the variant it changes. Name what changed, such as `B2 (B with search fields)`. Keep the old frames, so the user compares the old and the new side by side. Republish to the same link.

### 5. Capture the answer

Once a variant has won, capture the answer (which variant and why) the way the [SKILL](SKILL.md) describes. The winner enters the codebase as a rewrite in the project's own components.

## Anti-patterns

- **Variants that differ only in colour or copy.** That's a tweak, not a prototype. Real variants disagree about structure.
- **Sharing too much code between variants.** A shared `<Header>` is fine; a shared `<Layout>` defeats the point. Each variant should be free to throw out the layout.
- **Wiring variants to real mutations.** Read-only prototypes are fine. If a variant needs to mutate, point it at an in-memory stub: the question is "what should this look like", not "does the backend work".
- **Wireframe-grade variants.** Grey boxes, placeholder text and default browser styles hide the real differences. Each variant uses the project's real look.
- **Borrowed platform patterns.** An iOS Cancel link or Material grouped rows in an app whose design system has neither. Each variant uses only the patterns of the project's design doc.
- **Variants behind a switch.** Tabs, pages or a toggle between variants hide all but one. Every frame shows at once on the canvas.
- **Promoting the prototype directly to production.** The variant code was written under prototype constraints (no tests, minimal error handling). Rewrite it properly when you fold it in.
