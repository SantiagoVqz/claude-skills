# Screenshot budget: rules and rationale

Images are usually the largest thing the review loop puts in context, and the cost compounds: an attached image is re-read on every later step, so one taken early costs many times one taken late. Measured on one workspace across three UI sessions, `take_screenshot` accounted for 90-95% of all tool output. A single default-format page shot came back at about 640k characters against about 10k for the `take_snapshot` accessibility tree. Treat the ratio as the lesson, not the exact figures; they depend on the app and the host.

Never trade away review accuracy for size. The rules below are ordered by payoff, but rule 1 outranks all of them: **if an image is the only way to judge it, take the image.**

1. **Assert, don't look.** `take_snapshot` (structure, text, `uid`s) and `evaluate_script` (computed styles, `classList`, counts, element order) answer most questions a review asks, far more cheaply and more precisely than eyeballing a picture. Reach for an image when the judgment is visual: spacing, overlap, alignment, "does this look right".
2. **`filePath` when the image is an artifact, not evidence.** It writes the file to disk instead of attaching it to the response, so it never enters context. Good for before/after pairs and anything the user opens themselves. Two conditions: the MCP server must share a filesystem with the user (true for a locally launched server, not for a remote or containerized one), and it only saves anything if the file is not read back in. Reading it costs what attaching it would have.
3. **Compress only what compression won't damage.** `format: "jpeg"` with a `quality` around 80 is fine for layout, spacing, and overall impression. Stay on the default PNG when the thing being judged is fine detail (text rendering, 1px borders, exact color, gradients), because JPEG artifacts land precisely there and will invent bugs or hide them. PNG is not always the larger file; it depends on the content.
4. **Scope deliberately.** Pass `uid` to capture one element when one element is the subject. Use `fullPage: true` when below-the-fold or scroll-dependent layout is the point, and prefer JPEG for those, since they produce the largest results.

Take the shot late. A verification screenshot after a fix costs less than an exploratory one at the start, and is usually the one worth keeping.
