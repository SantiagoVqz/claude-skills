---
name: sv-prototype
description: Build throwaway prototypes as Claude artifacts for exploration of UI designs and answering design questions
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

Every prototype is one **Claude artifact**, published with the Artifact tool. The share is a link. The repo gets no prototype files, no route and no dev server. When the session has no Artifact tool, tell the user that the prototype needs one, and stop.

## Pick a branch

Identify which question is being answered, using the user's prompt, the surrounding code, or by asking if the user is around:

- **"Does this logic / state model feel right?"** → [LOGIC.md](LOGIC.md). Build one artifact (free-play buttons plus tabbed guided walkthroughs) that pushes the state machine through cases that are hard to reason about on paper, and that a non-developer can drive.
- **"What should this look like?"** → [UI.md](UI.md). Generate several radically different UI variations in one artifact, behind a floating bottom bar.

The two branches produce very different artifacts, so getting this wrong wastes the whole prototype. If the question is genuinely ambiguous and the user isn't reachable, default to whichever branch better matches the surrounding code (a backend module → logic; a page or component → UI) and state the assumption at the top of the prototype.

## Rules that apply to both

1. **Throwaway from day one, and clearly marked as such.** Put "Prototype" in the artifact title, and state the question at the top of the page.
2. **Trivial to run.** The artifact opens from its link, with nothing to install or start.
3. **No persistence.** State lives in memory. When the question is about persistence, fake the store in memory and label it as fake on the page.
4. **Skip the polish.** No tests, no error handling beyond what makes the prototype _runnable_, no abstractions. The point is to learn something fast.
5. **Surface the state.** After every action (logic) or on every variant switch (UI), render the full relevant state so the user can see what changed.
6. **Iterate in place.** Republish each change to the same artifact, so the link always shows the current prototype.
7. **Capture it when done.** Fold any validated decision into the real code. Record the answer (the verdict and the question it settled) with the artifact link as the context pointer: on the implementation issue when one exists, in the decisions log when `/sv-spec` or `/sv-prd` called the skill, else in the reply to the user. The artifact is the **primary source**, so the repo keeps only the validated decision.
