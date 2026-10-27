---
name: prototype
description: "Build throwaway prototypes as Claude artifacts to explore UI designs and answer design questions. Use when the user asks to prototype, mock up or see options, and before a UI change that the user must see first."
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

Every prototype is one **Claude artifact**, published with the Artifact tool. The share is a link. The repo gets no prototype files, no route and no dev server. When the session has no Artifact tool, tell the user that the prototype needs one, and stop.

## Pick a branch

Identify which question is being answered, using the user's prompt, the surrounding code, or by asking if the user is around:

- **"Does this logic / state model feel right?"** → [LOGIC.md](LOGIC.md). Build one artifact (free-play buttons plus tabbed guided walkthroughs) that pushes the state machine through cases that are hard to reason about on paper, and that a non-developer can drive.
- **"What should this look like?"** → [UI.md](UI.md). Generate several radically different UI variations in one artifact, side by side on one canvas.

The two branches produce very different artifacts, so getting this wrong wastes the whole prototype. If the question is genuinely ambiguous and the user isn't reachable, default to whichever branch better matches the surrounding code (a backend module → logic; a page or component → UI) and state the assumption at the top of the prototype.

Name the surface too: which app, and which page or flow. When the request does not name it and the user is present, ask one question with a recommended option before you build. Guess only when the user is away, and state the guess at the top of the prototype.

## Rules that apply to both

1. **Throwaway from day one, and clearly marked as such.** Put "Prototype" in the artifact title, and state the question at the top of the page.
2. **Trivial to run.** The artifact opens from its link, with nothing to install or start. It needs no app server, so stop each dev server that this session started before you build.
3. **No persistence.** State lives in memory. When the question is about persistence, fake the store in memory and label it as fake on the page.
4. **High fidelity on the surface, throwaway underneath.** The prototype looks and behaves like the real product: the project's fonts, colours, spacing and components, real copy, realistic data, and working hover, focus and open states. Read the project's design doc first: `DESIGN.md`, `docs/design-system.md`, or the doc that `AGENTS.md` names. Build each screen from the components it names, and use only the platform patterns it uses. Then read the tokens and component styles from the code (theme files, CSS variables, Tailwind config) or from the user's screenshots. The code behind it stays throwaway: no tests, no error handling beyond what makes the prototype _runnable_, no abstractions.
5. **Surface the state.** After every action, render the full relevant state so the user can see what changed.
6. **Iterate in place.** Republish each change to the same artifact, so the link always shows the current prototype.
7. **Check before the handover.** Run the script check, and wait for its result before you publish. Then open the published link in the browser at the target width, and look at every screen and state. Fix what you find, and republish before you send the link.
8. **Capture it when done.** Fold any validated decision into the real code. Record the answer (the verdict and the question it settled) with the artifact link as the context pointer: on the implementation issue when one exists, in the decisions log when `/spec` or `/prd` called the skill, else in the reply to the user. The artifact is the **primary source**, so the repo keeps only the validated decision.

## Excuses

| Excuse | Answer |
|---|---|
| "The implementer needs the HTML as a spec." | Give the implementer the artifact link and the decisions. The artifact stays the source. |

Add a row only when `/retro` finds a new excuse.
