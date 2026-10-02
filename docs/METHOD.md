# METHOD — how this fork of benilla is built

This tree is a fork of benilla, the from-scratch World of Warcraft 1.12.1 client in Rust and
Bevy (upstream: <https://github.com/samwhosung/benilla>). It reads the game's data from the
player's own install and speaks the original protocol to any 1.12.1 server. Upstream benilla
is the baseline. The reference client is how stock behaviour is known.

This fork is the baseline for significant client-side modifications. A surface keeps stock
1.12.1 behaviour until a change in this tree replaces it on purpose. The modification stays on
the client: the protocol stays the 1.12.1 protocol, and the game's data stays the player's
install.

## The rule for every change

A change is right when it does one of these, in one small piece, with the gates green:

- It makes an unmodified surface more like 1.12.1, or fixes a bug there, with evidence from the
  reference.
- It is a client-side modification. It names what 1.12.1 does, what this fork does instead, and
  why, and it records that departure where it lives: a CVar's `Deviates` or `Ours` row, or a
  comment naming the reference fact and the fork's choice.

Upstream records a departure as the maintainer's call and sends a new client feature to another
crate or a fork. This repository is that fork, so the modification belongs in this tree
(`docs/CONTRIBUTING.md`, "Modifications live in this tree").

## The loop

1. **The baseline first.** For anything that touches behaviour the stock client has, get the
   mechanism before changing it: its behaviour, a DBC field, a FrameXML line, a packet capture.
   The names and shapes under `reference/` are the 1.12.1 surface this fork tracks. A
   modification starts from that fact and then records the departure.
2. **Build it idiomatically.** Modern Bevy and Rust, performance woven in from the start.
   Implement the mechanism well; do not ape a quirk that is a bug.
3. **Measure, never eyeball.** Timing, delay, ordering and feel are settled with instruments:
   trace timestamps, byte-derived numbers, a numeric probe. A capture confirms an existence
   fact; it cannot measure time. Never search for a viewpoint: take the one simplest shot, and
   if it does not settle the question, hand over a precise script ("log in, look at X, does Y?").
4. **Close the loop on the symptom.** A bug reported as seen is closed by reproducing it at the
   reported spot first, fixing, and showing the same instrument clean there plus one adjacent
   state. Green gates and an existing mechanism are never that evidence.
5. **Prove the run before reading the result.** A live result is evidence once the run is valid
   from numbers: preflight banner clean, camera and body where intended, the subject in frame,
   the window long enough. A negative from an unproven run is not evidence.
6. **Commit small and often; land by pull request.** Atomic commits, explicit paths, on a
   branch; main moves only by a squash-merged pull request, one commit per piece of work.
   No "done" and no commit without saying what was verified and how the result was judged.

## Hard rules

- **Never commit anything from the install.** Art, models, sounds, maps, data: the install is
  read at runtime from a gitignored path, and everyone provides their own. Interface code is no
  exception: FrameXML and GlueXML run off the player's own patch chain, and `assets/ui` holds
  only benilla's own files.
- **The install is read-only.** benilla never writes into the WoW folder: no screenshot, log,
  cache or scratch file. `scripts/smoke.sh` fails a run that leaves the install changed.
- **Local state lives in one folder**, `benilla-config/`, at the repo root in a dev build and
  beside the binary in the player build; every path to it resolves through `crate::local_state`.
  Player settings are CVars persisted as a diff in `benilla-config/config.toml`.
- **The stock UI is the baseline; this fork's interface loads on top of it.** The core loads
  the stock 1.12 FrameXML off the player's own chain, byte for byte, and builds the engine
  verbs those files call, never stubbing one to make a file load. This fork's own interface
  (its options window, its game-menu look, its fixes to the stock Lua, and further client-side
  interface) is a layer that loads after the stock files and before third-party addons, the way
  an addon does. It is written against the 1.12 API unless a modification deliberately extends
  that API, listed in no addon list, and always on. Anything that changes what the stock UI
  does or shows lives in the layer. The layer may gain a file when a modification needs one.
  `the_layer_does_not_grow` names those files; update that list in the same change. A new Lua
  surface other addons can call is a modification and is recorded as one.
- **An unmodified setting's default is the reference's default.** Every option boots at the
  stock 1.12 value unless its row says otherwise. A modification that ships another value uses
  an explicit `Deviates` row with the reason. A CVar the reference lacks uses an `Ours` row
  with the reason. `defaults_stand_where_the_reference_column_says` fails a row that drifts
  from its claim. `the_options_that_leave_the_reference_are_this_list_and_no_other` names the
  `Deviates` rows; a new one updates that list in the same change.
- **Our code is MIT OR Apache-2.0**, which is a claim about provenance: no original client
  code, no bundled assets.

## Where things live

- `docs/METHOD.md`, this file: rules and method. Never state, never a log.
- `docs/MAP.md`: what is built, generated from the code by `scripts/genmap.sh` at every land.
  Read it to orient; never edit or commit it by hand.
- git: the history. No changelogs, no status docs, no "what we did" narratives.
- The code: a comment says what the code does and the 1.12 fact behind it, in a line. When
  this fork departs from that fact, the same comment names the departure. No history, no
  stories.

## Gates

- **The land gates**: `cargo fmt --all -- --check`, `cargo clippy --workspace --all-targets
  -- -D warnings`, `cargo test --workspace`, the doc-link and render-pass lints, the player
  build without the `dev` feature with its own tests, and the engine boot checks, as
  `scripts/gates.sh`. It runs on the tree that lands, before it lands; it is memoized on the
  tree. The tests that read the install or the addon corpus skip where the data is absent, and
  the gate prints the count; where the data is, a skip is a failure (`BENILLA_REQUIRE_DATA=1`).
  The workspace tests then run a second time with `WOW_DATA=` (no install), so a test that
  reads the install without opening with `wow_data_or_skip!` fails here and not on a clone.
- **Per round**: `scripts/check.sh`, scoped to the changed crates and their dependents. Run each
  gate once per round; `tee` the output to a file and grep the file.
- **A clean run** is the fourth gate: `scripts/smoke.sh`, a live login and logout against the
  local server. For wire work the gate is a live run with a trace (`WOW_MOVE_TRACE=<path>`,
  tags filtered), never a capture: capture mode has no network.
- **Platform seams**: a `cfg(target_os)`, a `[target.'cfg(…)']` dependency, a `#[link]` or an
  `extern "system"` is invisible to the gates of the platform you are on. Say in the commit
  which platforms you built.

## The local server

benilla talks to any 1.12.1 server: `WOW_HOST` names it (default `localhost`), `WOW_USER` and
`WOW_PASS` together log in without typing, `WOW_CHAR` picks the character. There is no default
account. These bind every session and every agent:

- A scripted run logs in as the account its checkout declares in `.probe-identity` (the three
  variables, one per line, never committed), or as the three variables name; never as a
  player's, because a login kicks whoever holds the account, and the client refuses a scripted
  login from a checkout on any account but the declared one.
- Every unattended run says so: `WOW_UNATTENDED=1`. An agent's run is silent: `WOW_NOSOUND=1`.
- No unattended combat probes.
- Anything about hostility, reaction colour, nameplates, threat, damage or breath runs with
  `WOW_GM=off`.
- Read the preflight banner before debugging anything else.

The switches for such a run are `docs/CONTRIBUTING.md`, "Running it unattended".
