---
name: research
description: "Research how to build or integrate something before the work starts: how it works, the options, the APIs to use, and the risks, from primary sources, as a cited report in the repo. Use when the user runs /research, asks to research, look up or compare something, asks how to connect or integrate a service, or another skill needs facts from docs, specs or the web."
argument-hint: "<question>"
metadata:
  credits:
    - skill: research
      author: Matt Pocock
      organisation: AI Hero
      url: "https://github.com/mattpocock/skills/blob/main/skills/engineering/research/SKILL.md"
    - skill: deep-research
      author: Anthropic
      organisation: Anthropic
      url: "claude.ai built-in skill: anthropic-skills:deep-research"
---

# Research

`/research` answers a question with a cited report that the user can build from. You are the **coordinator**: you scope the question, start the researchers, and give their notes to a writer. The subagents search and read. You keep your context for the user's work.

Each claim in the report traces to a **primary source**: the docs, spec, regulation, source code, changelog or first-party API that owns the fact. A blog post, forum answer or AI summary that repeats the fact is a lead to the owner, not a citation.

## 1. Scope

Read the question. Then read the **stack** of the app, when the work runs in a repo: the language, the framework, the hosting, and each integration that is already there, such as a payment or email provider. Take it from the manifest files, such as `package.json`, and the config. The stack is a constraint for each researcher: an SDK for the wrong language is no answer.

Ask with the question tool only when the answer changes what the researchers look for: a term with two meanings, a missing version, country or date, or a name that points to two things. Ask two questions at most.

Then pick the kind:

- **Integration**: how to connect the app to a service, an authority or a standard, such as SAT e-invoicing, a bank feed or an OAuth provider. A survey with the four facets below.
- **Lookup**: one set of facts with one owner, such as how an API pages its results or what a config flag does. One researcher, and its notes are the report.
- **Survey**: a comparison or a question with distinct facets that is not an integration. One researcher per facet, 3 to 5. The facets do not overlap, and together they cover the question.

The facets of an integration:

1. **Process**: how the integration works end to end. The parties, the flow of data, the rules or regulation that apply, and the credentials, certificates or registrations that the app or the user must get.
2. **Options**: each way to integrate. Direct with the owner, through each main provider, or with an open source library. For each option: cost, limits, support, and the fit with the stack.
3. **APIs**: for each option that fits, the endpoints or SDK, the auth, the data formats, the rate limits, the sandbox, and the library for the stack.
4. **Operation**: testing, errors and retries, failure modes, compliance duties such as retention, and each deprecation or deadline that is announced.

When another skill calls this one, take its question and constraints as given, and ask nothing.

Completion: you have the question in one sentence, the stack, the constraints and the kind. For a survey, you have each facet with its key questions.

## 2. Place

Pick a slug of 2 to 5 lowercase words, joined by hyphens, such as `sat-cfdi-integration`.

The report goes where the repo keeps such notes. Look for a folder such as `docs/research/` or `docs/notes/`, and match its convention. With none, use `docs/research/<slug>.md`. Outside a repo, use `research/<slug>.md` in the working directory.

When a report on the same topic exists, keep it. Give the new report a slug that says what this run adds, or `<slug>-2`. The earlier report is background for the writer.

The notes go in `<scratchpad>/research/<slug>/`, because they are working files, not repo content.

Completion: you have the absolute report path, which names no existing file, and the absolute notes folder. The parent folders of both exist.

## 3. Research

Start each researcher with the Agent tool, `subagent_type: general-purpose`. Start all of them in one message, so that they run in parallel. Give each one this prompt:

```text
Research <narrow topic>.

Objective: <what the notes must cover>

Key questions:
- <question>

Where to look: <the primary sources that own these facts, such as an official portal, a docs site, a regulation, a repo, release notes, or files in this repo>

Stack: <language, framework, hosting, existing integrations, or "none">

Constraints: <version, country, date and other bounds from the question>

Save your notes to <absolute path>

First, read <absolute path of this skill's folder>/RESEARCHER.md and follow it.
```

For a lookup, the save path is the report path. For a survey, it is `<notes folder>/<facet>.md`.

Tell the user in one line what runs, then go on with the user's other work until each researcher reports back.

Completion: each researcher reported back, and each file that you named exists.

## 4. Gaps

Read the summary of each researcher. A **blocking gap** is a key question with no cited answer, where the report cannot answer the user's question without it. For blocking gaps, start one more round of researchers, on the gaps only.

One gap round at most. After it, go to step 5 with what you have. A gap that is still open goes into the report as a gap.

Completion: no gap blocks the answer, or the gap round reported back.

## 5. Write

For a lookup, go to step 6.

For an integration or a survey, start one writer with the Agent tool, `subagent_type: general-purpose`:

```text
Read the notes in <notes folder> and write a report that answers: <the question in full>.

Kind: <integration | survey>

Stack: <the stack from step 1, or "none">

Earlier report to build on: <absolute path, or "none">

Save the report to <report path>.

First, read <absolute path of this skill's folder>/WRITER.md and follow it.
```

Completion: the report exists at the report path.

## 6. Deliver

Read the report. Leave it uncommitted: the user decides whether it belongs in the repo history.

When another skill called this one, give back the report path and the answer: the answer paragraph of a survey or an integration, or the takeaways of a lookup. That skill goes on from there.

## Report

Report path · kind · the answer in 3 to 5 sentences · each open gap · next step: for an integration, `/issue idea` or `/spec`, with the report path as input.
