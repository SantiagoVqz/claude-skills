# Glossary and ADR format

## GLOSSARY.md

One file at the repo root. Create it when the first term is settled.

```markdown
# <Project name>

<One or two sentences: what this project is.>

## Language

**Habit**:
A repeated action that the user wants to track each day.
_Avoid_: Task, goal
```

- One or two sentences per term. Say what the term is, not what it does.
- Pick one word per concept. Put the other words under `_Avoid_`.
- Add only words that are specific to this project. General programming words stay out.
- Keep implementation details out. The glossary is not a spec.

## ADRs

One file per decision in `docs/adr/`, numbered: `0001-<slug>.md`. Find the highest number and add one. Create the folder when the first ADR is needed.

```markdown
# <Short title of the decision>

<One to three sentences: the context, the decision, and the reason.>
```

Add a section only when it has value:

- **Considered options**: when a rejected option is likely to come back.
- **Consequences**: when an effect downstream is not obvious.
