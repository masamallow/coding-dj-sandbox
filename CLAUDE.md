# Claude Memory

## Purpose

A personal sandbox for learning live coding music ("Coding DJ") on macOS.

The repository serves two parallel goals:
1. Develop live-coding music performance skills using **TidalCycles**.
    - If necessary, we may use Strudel as a supplementary tool. 
2. Use Tidal's Haskell foundation as a vehicle for **learning Haskell**.

Assume strong general programming fundamentals; do not assume Haskell or DSP knowledge.

## Primary Stack

- **Live coding language**: TidalCycles (Haskell DSL for pattern-oriented music)
- **Audio engine**: SuperCollider + SuperDirt (`sclang` / `scsynth`)
- **Editor**: VS Code with the `tidalcycles.vscode-tidalcycles` extension
- **Haskell toolchain**: GHC 9.6.x and cabal 3.14.x via GHCup
- **OS**: macOS on Apple Silicon (M3 Pro, 36 GB)

Strudel (https://strudel.cc) is the popular browser-based alternative used by several reference performers,
but this repository deliberately standardizes on TidalCycles to gain Haskell exposure alongside live-coding practice.
**Do not propose migrating to Strudel** unless the user explicitly opens that direction.

## Important Project Status (2025+)

TidalCycles' upstream development moved from GitHub to **Codeberg** in mid-2025.
The GitHub `tidalcycles/Tidal` and `tidalcycles/strudel` repos were archived (read-only) on 2025-06-13 and 2025-06-19 respectively.

Active sources:
- Tidal: <https://codeberg.org/uzu/tidal>
- Strudel: <https://codeberg.org/uzu/strudel>
- Latest Tidal release at the time of writing: **1.10.0 ("waffle"), 2025-06-08**

When researching Tidal behavior or filing/searching issues, prefer Codeberg over the archived GitHub repos.
Older blog posts and tutorials may still link to GitHub; treat those as informational, not the source of truth.

## Repository Layout

- `patterns/` — `.tidal` files. One file per piece, experiment, or exercise.
- `BootTidal.hs` (workspace root, **optional**) — Custom Tidal boot file.
  Absent by default; the bundled Tidal package boot file is used.
  When created, the VS Code extension setting `tidalcycles.useBootFileInCurrentDirectory` must be flipped to `true` for it to be picked up.
- `<Module>.hs` (workspace root) — Additional Haskell helper modules, imported from `BootTidal.hs` (e.g. `MyHelpers.hs`).
  Keep flat at root so `ghci`'s default search path finds them without configuration.

## File Conventions

- Tidal patterns use the `.tidal` extension (associated with the VS Code extension and used by tooling for syntax handling).
- `.tidal` files live under `patterns/`. One artistic idea per file.
  Iterate inside the file, including through commented-out variants, rather than spawning new files for tiny tweaks.
- Haskell utility modules use `.hs` and live at the **workspace root**, not in a subdirectory.
  This matches the default `ghci` search path used by Tidal's editor plugins and avoids per-project `-i` flags.

## Common Commands

Update Tidal Haskell library (after a Codeberg release):

```bash
cabal update
cabal install tidal --lib
```

Verify Tidal is importable from GHCi:

```bash
ghci -package tidal
# at the prompt:
# > import Sound.Tidal.Context
# > tidal_version
```

Verify the Haskell toolchain:

```bash
ghc --version    # expect 9.6.x
cabal --version  # expect 3.14.x
```

SuperCollider startup, the SuperDirt boot block, and the VS Code "evaluate line" (`Ctrl+Enter`) flow are GUI / IDE workflows.
Do not script them or recommend automating them in CI.

## Workflow Rules

- Before suggesting an installation or upgrade step that touches SuperDirt Quarks,
  check whether the current Tidal release notes on Codeberg require a particular SuperDirt version (currently v1.7.4+).
- When suggesting Haskell that goes into `BootTidal.hs` or imported helper modules at the workspace root, ensure compatibility with **GHC 9.6**.
  Avoid features added in 9.8+ unless explicitly approved.
- Never assume the user wants Strudel output, even if examples online use Strudel syntax. Translate to TidalCycles syntax when the source is Strudel.
- For Tidal-specific documentation lookups, prefer direct web fetches from <https://tidalcycles.org> and <https://codeberg.org/uzu/tidal> over Context7.
  Context7 indexes from GitHub; the active Tidal sources are on Codeberg and may be missing or outdated in the Context7 index.
  Use Context7 freely for non-Tidal libraries (general Haskell ecosystem packages such as `text`, `aeson`, `mtl`, etc.).

## Out of Scope

- DAW integration (Logic, Ableton Live) is parked until baseline Tidal fluency is reached.
- Visual live coding (Hydra) is parked.
- Strudel-based work is parked unless the user explicitly asks for it.
- Audio rendering / mastering pipelines are parked.

## Key References

- Tidal docs: <https://tidalcycles.org/>
- Tidal source (active): <https://codeberg.org/uzu/tidal>
- Tidal Club forum: <https://club.tidalcycles.org/>
- Strudel REPL: <https://strudel.cc/>
- Strudel source (active): <https://codeberg.org/uzu/strudel>
- SuperCollider: <https://supercollider.github.io/>
- SuperDirt: <https://github.com/musikinformatik/SuperDirt>
- VS Code extension: <https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles>
- GHCup (Haskell toolchain): <https://www.haskell.org/ghcup/>
