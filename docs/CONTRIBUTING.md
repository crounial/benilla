# Contributing

This tree is a fork of [benilla](https://github.com/samwhosung/benilla). Upstream is a faithful
1.12.1 client and the baseline. This fork is where significant client-side modifications are
made. A change is accepted when it modifies the client on purpose, or when it makes an
unmodified surface more like 1.12.1 or fixes a bug there, with the evidence the change needs, in
one small piece, with the gates green.

## Where to start

Read `docs/METHOD.md`, then `docs/MAP.md`, then `docs/FORK.md`. The baseline is this tree and
the 1.12.1 facts under `reference/`. `docs/FORK.md` is what this tree already changes from
upstream. A modification begins by naming the stock behaviour it changes, and updates its row
there in the same change. Upstream's
[issues](https://github.com/samwhosung/benilla/issues) describe gaps between upstream benilla and
1.12.1. They map the baseline. This fork's modifications are decided here.

## What gets in

- A client-side modification: input, interface, presentation, or other client behaviour. Name
  what 1.12.1 does, what this fork does instead, and why. Record the departure where it lives.
- A fix for a bug, with how to see it before and after. Say whether the expected behaviour is
  stock 1.12.1 or a modification of this fork.
- A step that keeps an unmodified surface aligned with 1.12.1: a missing packet, verb, window,
  effect or behaviour, done the way the real client does it.
- A correction where an unmodified surface and the reference disagree, with the reference fact
  stated.
- Whatever the stock 1.12.1 client loads from a patch, an unmodified surface still loads:
  models, textures or data rows that 1.12.1 shows and this fork does not are a bug, unless a
  modification has said it drops them.

## What does not

- A server, or a client that stops speaking the 1.12.1 protocol. Modifications stay on the
  client. The game's data stays the player's own install.
- Anything from a WoW install: art, models, sounds, maps, data, and the stock interface code
  (FrameXML and GlueXML), which runs off the player's own install (`docs/METHOD.md`).
- An unrelated pile of changes. One concern at a time, small enough to read in one sitting. A
  large modification lands as a series of those.

## Modifications live in this tree

Upstream sends a feature 1.12.1 does not have to a crate of its own that adds Bevy plugins
through `benilla_app::run_with`, as `crates/benilla-app/examples/extended_launcher.rs` shows, or
to a fork. This repository is that fork. The default home for a client-side modification is this
tree.

`run_with` remains the path when a piece should stay a plugin outside the client. A client
started through `run_with` says `extended` in its build line, so its reports read apart from
this fork's. The crate keeps its own settings, never rows in the CVar table, which every addon
reads. That path has no stable API: a crate pins the revision it builds on.

## How a change is judged

1. `scripts/gates.sh` is green: fmt, clippy with warnings denied, the workspace tests (once
   with the client data, once without, so a test that reads the install has to declare it), the
   doc-link and render-pass lints, the player build with its own tests, and the engine boot
   checks. CI on a pull request whose branch lives in another repository runs the gates that
   need neither the install nor a display, on Linux. The rest run on the maintainer's machine
   before it lands. A branch of this repository runs the full chain before it lands.
2. The baseline fact is stated when the change touches stock behaviour: what 1.12.1 does, and
   where that is known from (the client's behaviour you observed, a DBC field, a FrameXML line,
   a packet capture). The names and shapes under `reference/` are the 1.12.1 surface this fork
   tracks.
3. A modification also states what this fork does instead. The departure is recorded where it
   lives: a CVar's `Deviates` or `Ours` row, or a comment naming the reference fact and the
   fork's choice, and a row in `docs/FORK.md`. `the_layer_does_not_grow` names the interface
   layer's files; a new layer file
   updates that list in the same change. A new `Deviates` row updates
   `the_options_that_leave_the_reference_are_this_list_and_no_other` in the same change.
4. A comment where it matters, one line, saying what the code does, the 1.12 fact behind it,
   and the departure when there is one. No history.
5. The commit message says what changed, for a player or a developer, in one line.

## Landing it

Work sits on a branch, in atomic commits. Main moves by a squash-merged pull request, one
commit per piece of work. The commit says what changed and what was verified. `scripts/gates.sh`
is green on the tree that lands. One concern per change. A change whose behaviour is out of
scope under "What does not" stops there.

## Setting up

- **The toolchain.** Stable Rust (`rust-toolchain.toml` adds clippy and rustfmt) and a C
  compiler, because the client's Lua is vendored and built from source. On macOS the Xcode
  command line tools, which also supply libclang for the audio bindings; on Linux the ALSA and
  udev development packages and pkg-config. `python3` runs two of the gates.
- **A 1.12.1 install of your own.** `WOW_DATA=<its Data folder>`, or a `WoW` link at the repo
  root, which only a dev build sees: the player build looks for `Data/` or `WoW/Data/` beside
  the binary. benilla reads the install and never writes into it. `WOW_DATA=` (set, empty)
  means "no install", which is how the no-install boot is tested on a machine that has one.
- **Without the install, green is hollow.** Well over a thousand tests read the install and skip
  when it is absent, and a few dozen more read a corpus of vanilla addons
  (`BENILLA_ADDON_CORPUS=<a folder of addons>`, or a `wow-addons-vanilla` link at the root),
  third-party content that is not in this repo. `scripts/gates.sh` and `scripts/check.sh` print
  how many tests skipped and why. Where the data is, `BENILLA_REQUIRE_DATA=1` turns a skip into a
  failure, and the gates set it themselves when the install and the corpus both resolve.
- **A server to test against.** Any 1.12.1 server; `WOW_HOST` names it (default
  `localhost:3724`). A scripted run has no default account: `WOW_USER`, `WOW_PASS` and
  `WOW_CHAR` name a test account on your server whose login kicks nobody, all three, either in
  the environment or in a `.probe-identity` file at the repo root (one per line, never
  committed), and `scripts/smoke.sh` (the live login gate) refuses without them. `WOW_CHAR`
  must already be on the account, since the client creates a character only when asked:
  `WOW_PROBE_CHARCREATE=<name> WOW_PROBE_CHARCREATE_KEEP=1`, run without `WOW_CHAR`, makes it.
  The probes drive the body with GM commands, so give that account the top GM level.
- **Running it unattended.** The rules are `docs/METHOD.md`, "The local server"; these are the
  switches.
  - `WOW_UNATTENDED=1` reconnects instead of waiting at a dialog, and exits non-zero on a login
    it cannot pass. `WOW_NOSOUND=1` runs silent. A capture (`WOW_CAPTURE`) is both, and a rig
    (`WOW_RIG`) is unattended. `WOW_ALLOW_ACCOUNT=1` overrides the account guard.
  - On vmangos, `WOW_RIG="tauren druid 60 gear:heal-preraid-bis spec:heal-preraid-bis
    at:ThunderBluff"` finds or creates that character on the account and applies the server's
    premade sets (`WOW_RIG="gear:?"` lists them). `WOW_PROBE_CHAT="<command>"` sends one GM
    command and logs the reply as `net: server says`. An account named `probe` and digits is
    shielded: every world entry sends `.cheat god on`, `.die` clears it for a death test, and
    `WOW_GOD=off` leaves it off.
  - A trace is `WOW_MOVE_TRACE=<file>`, filtered with `WOW_MOVE_TRACE_TAGS` (`"move,snd,in"`) and
    ended by `WOW_PROBE_EXIT_AT=<seconds>`; grep it for the `rly` and `snd` lines.
  - A capture runs through `scripts/visual.sh`, whose recipe is the header of
    `crates/benilla-app/src/capture/mod.rs`. Pixel questions go through `benilla-visual crop`,
    `series` and `hotspot`.
- **The loop.** `cargo play` builds and runs the play profile. `scripts/check.sh` verifies a
  round of work; `scripts/gates.sh` is the full chain, and it opens a window for the engine boot
  checks, so it needs a display. `WOW_STOCK_UI=1` boots a dev build on the stock interface
  alone, without benilla's layer. Work on a branch.

## Reporting a bug

Open an issue: what you did, what you saw, and what should have happened. Say whether that
expectation is stock 1.12.1 behaviour or a modification of this fork. Include the `benilla build`
line from the start of the terminal output, your platform and the server you ran on. The Discord
linked from the README is the upstream project's.

Working with an AI agent is expected. The agent reads `AGENTS.md`, and the same rules bind it.
