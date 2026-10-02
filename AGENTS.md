# benilla

A fork of the from-scratch World of Warcraft 1.12.1 client in Rust and Bevy (upstream:
<https://github.com/samwhosung/benilla>). Upstream benilla is the baseline. This tree is where
significant client-side modifications are made. A surface keeps stock 1.12.1 behaviour until a
change here replaces it on purpose.

Read, in this order:

1. `docs/METHOD.md` — the rules and how we work. Binding for every session.
2. `docs/MAP.md` — what is built right now, generated from the code. Orient here before
   touching anything.
3. `docs/CONTRIBUTING.md` — what gets in and how a change is judged.

The rest of the root is code and data: `crates/` the workspace, `reference/` the 1.12 name
catalogues the tests check against, `scripts/` the gates and instruments, `third_party/`
vendored code.

@docs/METHOD.md
