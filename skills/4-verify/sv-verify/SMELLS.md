# Smells

Fowler's code smells, from _Refactoring_, chapter 3. Each one is a judgment call, never a hard finding. A written rule of the repo wins over a smell.

- **Mysterious name**: a name does not say what the thing does or holds. Rename it.
- **Duplicated code**: the same logic is in two places in the diff. Extract it, and call it from both.
- **Feature envy**: a function uses the data of another module more than its own. Move it to that data.
- **Data clumps**: the same few values always travel together. Make them one type.
- **Primitive obsession**: a string or a number stands for a domain concept. Give the concept its own type.
- **Repeated switches**: the same switch on the same type is in more than one place. Use one map, or polymorphism.
- **Shotgun surgery**: one change needs edits in many files. Put the things that change together in one module.
- **Divergent change**: one module changes for unrelated reasons. Split it.
- **Speculative generality**: a parameter, hook or abstraction that the ticket does not need. Remove it.
- **Message chains**: a long `a.b().c().d()` walk. Hide the walk behind one function.
- **Middle man**: a module that only passes calls on. Call the target directly.
- **Refused bequest**: a subtype that ignores most of what it inherits. Use composition.
