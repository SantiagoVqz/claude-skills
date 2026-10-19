# Domain docs

The glossary and the ADRs record this project's words and its hard decisions. `/sv-spec` writes them. Every other skill reads them.

## Read before you explore

- `<glossary>` at the repo root. This is the glossary file. Each skill that names the glossary means this file.
- The ADRs in `docs/adr/` that touch the area you work in.

A missing file means that nothing is recorded yet. Continue without it.

## Use the glossary's words

Name each domain concept with its glossary term: in issue titles, test names, code, commit messages and PR bodies. A concept that the glossary does not have is a gap. Write it in your report, so that the next `/sv-spec` can settle it.

## Surface ADR conflicts

When your work contradicts an ADR, stop and say so before you continue. Name the ADR and give the reason to reopen it.
