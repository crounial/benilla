# benilla

A fork of the from-scratch World of Warcraft 1.12.1 client in Rust and Bevy (upstream:
<https://github.com/samwhosung/benilla>). Upstream benilla is the baseline. This tree is where
significant client-side modifications are made. A surface keeps stock 1.12.1 behaviour until a
change here replaces it on purpose.

Read, in this order:

1. `docs/METHOD.md` — the rules and how we work. Binding for every session.
2. `docs/MAP.md` — what is built right now, generated from the code. Orient here before
   touching anything.
3. `docs/FORK.md` — what this tree changes from upstream benilla. Update its row in the
   same change as a modification.
4. `docs/CONTRIBUTING.md` — what gets in and how a change is judged.

What the real client does comes from [benilla-re](https://github.com/samwhosung/benilla-re), the
reverse engineering of 1.12.1, before you build: clone it beside this repo and grep it, or look an
address up at `https://samwhosung.github.io/benilla-re/?0x5e6853`. `docs/CONTRIBUTING.md`, "The
reference", says how to read it and what to do when it has a gap.

The rest of the root is code and data: `crates/` the workspace, `reference/` benilla-re's
tables vendored at a pinned commit, which the tests check against, `scripts/` the gates and
instruments, `third_party/` vendored code.

@docs/METHOD.md
