## Operational Loop
Every time you take on a task, execute these steps sequentially:
1. **Grounding**: Read `.claude/rules/` matching the current task scope.
2. **Context Map**: Search Architecture Decision Records (`docs/adr/`) and critical user flows before writing code.
3. **Execution**: Make changes in isolated, minimal steps.
4. **Verification**: Run `npm test` and `npm run lint` locally before declaring completion.
5. **Self-Correction**: If a check fails, read the specific error message and attempt remediation up to 3 times.

## Codebase Principles
- **No Untyped Boundaries**: Strict TypeScript (`noImplicitAny`, no `any`/`unknown` unless isolated in API validation layer).
- **Colocated Tests**: Every new file must have a corresponding test/snapshot file.
- **Fail Fast**: Explicit error messages with clear remediation paths over generic fallbacks.

## My thoughts
There's a lot of things that I would like to keep or to get inspired from the Matt Bakuk. Well first of all is the grilling. Grilling I feel it's really good. And I also like how we're getting this side of the docs ADR uh as well.

So the domain modeling part I think it's really good and it will help us. So we could probably keep that. I love the triage as well because when we're working sometimes tickets come to life and instead of like being able to create the exact ticket it's nice to have this availability that later we can triage some tickets right we can triage some tickets classify it and further act up on the information of the ticket if we have to learn more about it or design an implementation or whatever I do like the triage.

For execution I, really like this really simple implement that I can loop or use a goal or whatever to implement it. And I like that we have by default to work with TDD. The only thing that I think is missing in the MatBlocker skills is the general use of simplify or maybe optimizing the code base, which I don't think it's really necessary, so we might skip it for them.

And the workflow it's I think one of the key things for me is like being able to really make sure that the grilling session with the ADR docks or if we use Wayfinder which is a skill that I do want in my new in my new skills is to be able to have everything when we create tickets for implementation to have them be vertical slices like really strictly vertical size slices that are all that all are like small sub features of a bigger feature or s or a specification file because the plan here is to have multiple agents working at the same time implementing in parallel work trees as long as the tickets are not blocked and I don't want to push like half-made features as a whole I want them to be like if it's a change that involves back end and front end for those to be bundled up together and pushed together, right?

And yeah, that's basically it for my requirements, TDD implement triage, grill with docs or something similar. And I also want everything to be really simple and minimal. I don't want to overflow with instructions on the skills to prevent the context window for overflowing the context or in general being able to have clear decisions and fully understand as a human and a machine like what is being done there why it works which I think Matt Bakuk already do does a really good job in it but I do want to further improve it so that I can at least for me understand what we are doing, what it s skill is for.

And whenever I see any gaps on the implementation of any of those skills to go in and update based on my needs. 