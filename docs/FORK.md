# Fork — departures from upstream benilla

Upstream is <https://github.com/samwhosung/benilla>. This file lists what this tree
does that upstream does not. It is the current set, read by people and by agents
before they change behaviour. Git holds the history. A modification adds, edits, or
removes its row in the same change.

The pin is `upstream/main` at `ffdc206a` (World-enter queries wait for the player's
create, as 1.12.1 sends them). When this tree takes new upstream commits, update the
pin. Leave out any commit that is already on `upstream/main`.

A row states what 1.12.1 does, what upstream does when that differs, what this fork
does, and the file that holds the departure. Name a companion that lives outside
this tree, with its path. The comment at the code still names the departure. This
file does not replace that comment.

## Player-visible

### Gnome paladin

1.12.1 offers paladin to human and dwarf only. `CharBaseInfo` has no gnome paladin
(race 7, class 2). Upstream lists the shipped pairs and no others.

This fork offers gnome paladin on the create screen. The pair is `FORK_COMBOS` in
`crates/benilla-formats/src/characters/customization.rs`. There is no
`CharStartOutfit` row for it. The preview uses the gnome warrior's shirt, pants and
boots and the dwarf paladin's hammer. A DBC row for (7, 2), when one is present, is
left as the file ships it.

Creation still depends on the server. This tree has no world-database rows. The
vmangos rows that admit the pair, and that open the dwarf paladin quest chain to
gnomes, are `storage/database/custom-sql/gnome-paladin.sql` in the
`vmangos-deploy-podman` checkout. The human paladin chain stays human-only.

### V-key nameplates at 41 yards

1.12.1 hardcodes a 20-yard cap on V-key nameplates (`0x60f600`). Upstream keeps that
cap.

This fork draws those plates out to 41 yards, measured from the player's position to
the unit. The cap is inclusive: a plate at 41 yards stays, and the next yard drops
it. `MAX_DIST_YD` in `crates/benilla-app/src/vplates.rs`. Chat bubbles stay on the
20-yard gate. Overhead names still have no distance cap.

## Repository

These change how the tree is described and launched. They leave play unchanged.

- `docs/METHOD.md`, `docs/CONTRIBUTING.md`, `README.md`, `Agents.md`, and the GitHub
  issue and pull-request templates describe this tree as the modification fork.
  Upstream's copies describe a faithful 1.12.1 client.
- `run-benilla.ps1` starts `target/release/benilla.exe`. `-User`, `-Password`
  (`-Pass` is the same parameter), `-Char` and `-DataFolder` are optional and set
  `WOW_USER`, `WOW_PASS`, `WOW_CHAR` and `WOW_DATA` when the caller supplies them.
  `-Password` is required when `-User` is passed.
