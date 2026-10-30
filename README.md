# Coding DJ Sandbox

[![tidal on Hackage](https://img.shields.io/hackage/v/tidal?label=tidal%20on%20Hackage&logo=haskell&logoColor=white)](https://hackage.haskell.org/package/tidal)
[![Haskell: GHC + cabal via GHCup](https://img.shields.io/badge/Haskell-GHC%20%2B%20cabal%20via%20GHCup-5e5086?logo=haskell&logoColor=white)](https://www.haskell.org/ghcup/)
[![audio: SuperCollider + SuperDirt](https://img.shields.io/badge/audio-SuperCollider%20%2B%20SuperDirt-2d2d2d)](https://codeberg.org/musikinformatik/SuperDirt)
[![editor: VS Code](https://img.shields.io/badge/editor-VS%20Code-0078d7)](https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles)
[![platform: macOS (Apple Silicon)](https://img.shields.io/badge/platform-macOS%20(Apple%20Silicon)-000000?logo=apple&logoColor=white)](./docs/setup.md)
[![upstream: Codeberg](https://img.shields.io/badge/upstream-Codeberg-2185D0?logo=codeberg&logoColor=white)](https://codeberg.org/uzu/tidal)
[![license: TBD (MIT planned)](https://img.shields.io/badge/license-TBD%20(MIT%20planned)-lightgrey)](#-license)

A sandbox for **Coding DJ** (live-coding music) on macOS, built on TidalCycles + SuperCollider + VS Code,
with Haskell catch-up as a parallel track through Tidal's Haskell foundation.

## 🎯 Goals

- Develop live-coding music performance skills with [TidalCycles](https://tidalcycles.org/).
- Use Tidal's Haskell foundation as a vehicle for learning Haskell.

Patterns and examples default to TidalCycles.  
[Strudel](https://strudel.cc/) is Tidal's browser-based sibling and a handy way to play without the SuperCollider stack; translating between the two is routine.

## 🧰 Stack

| Role | Choice |
| --- | --- |
| Live-coding language | TidalCycles (a Haskell DSL for pattern-oriented music) |
| Audio engine | SuperCollider + the SuperDirt Quark (`sclang` / `scsynth`) |
| Editor | VS Code with the `tidalcycles.vscode-tidalcycles` extension and the Haskell Language Server |
| Haskell toolchain | GHC and cabal via GHCup; the `tidal` library stays repo-scoped through a minimal cabal package |
| OS | macOS on Apple Silicon |

## 🗂️ Project structure

```text
.
├── patterns/                 # *.tidal files (live-coding patterns), one idea per file
├── src/*.hs                  # (optional) helper Haskell modules, registered in the cabal file
├── boot/ghci                 # REPL wrapper (cabal repl) spawned by the VS Code extension
├── boot/superdirt_startup.scd   # SuperCollider startup file: boots the server and starts SuperDirt
├── boot/quarks.txt           # SuperCollider Quarks to install (SuperDirt pinned to a release, plus dependencies)
├── docs/setup.md             # environment setup guide
├── BootTidal.hs              # Tidal boot script piped into the REPL
├── coding-dj-sandbox.cabal   # minimal cabal package depending on tidal
├── hie.yaml                  # HLS loads src/ via cabal and ignores patterns/ and BootTidal.hs
├── .vscode/settings.example.json   # template for the git-ignored .vscode/settings.json
├── AGENTS.md                 # instructions for AI coding agents (imported by CLAUDE.md)
└── README.md
```

`BootTidal.hs` is the boot file shipped with the current Tidal release;
the VS Code extension auto-detects it at the workspace root, and local additions go below the `-- Local additions` marker at its end so upgrades diff cleanly.  
Helper modules (e.g. `src/MyHelpers.hs`) are registered under `exposed-modules` in `coding-dj-sandbox.cabal` so both the REPL and HLS see them.  
`boot/` holds the start-up pieces of both engines: `boot/ghci` for the Tidal REPL, and `boot/superdirt_startup.scd` plus `boot/quarks.txt` for the SuperCollider side (the startup file stays close to the upstream example, with deviations marked `local:`).

## ✅ Prerequisites

- macOS (tested on Apple Silicon).
- Haskell toolchain via [GHCup]: GHC and cabal (versions are managed by GHCup, not pinned in this repo).
- [SuperCollider] with `sc3-plugins`; the `SuperDirt` Quark and its dependencies are installed from `boot/quarks.txt`.
- VS Code with the extensions recommended in [.vscode/extensions.json](./.vscode/extensions.json):
  - [`tidalcycles.vscode-tidalcycles`][vscode-tidal] for `.tidal` evaluation.
  - [`haskell.haskell`][vscode-haskell] for the Haskell Language Server,
    which provides the Ormolu formatter and surfaces HLint diagnostics.  
    Formatting and linting policy is delegated to these tools (see [.claude/rules/haskell-style.md](./.claude/rules/haskell-style.md)).
  - `haskell.language-haskell` for syntax highlighting, which `.tidal` files reuse.
- Ormolu and HLint CLIs for formatting and linting outside the editor: `cabal install ormolu hlint`.

> [!NOTE]
> The Tidal extension sees little upstream activity: as of 2026-10 it has had no release since 2025-05, and the official Tidal tutorial assumes the Pulsar editor.  
> It works with the current Tidal release, but check the [Marketplace page][vscode-tidal] and the [editor docs](https://tidalcycles.org/docs/getting-started/editor/) before relying on newer features.

[GHCup]: https://www.haskell.org/ghcup/
[SuperCollider]: https://supercollider.github.io/
[vscode-tidal]: https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles
[vscode-haskell]: https://marketplace.visualstudio.com/items?itemName=haskell.haskell

## 🚀 Getting started

[docs/setup.md](./docs/setup.md) walks through the whole environment, from SuperCollider and SuperDirt to the VS Code wiring and a smoke test.  
The repository side comes down to four steps: one in the SuperCollider IDE, three from the repo root.

Install the SuperCollider Quarks listed in `boot/quarks.txt` and recompile the class library, once per machine.  
[docs/setup.md](./docs/setup.md#4-superdirt) has two procedures: `Quarks.load` of the whole set for a SuperCollider dedicated to this repository (it removes every other Quark first), or `Quarks.install` of SuperDirt alone for a shared one.

Build the repo-scoped Tidal library:

```sh
ghc --version
cabal --version
cabal update
cabal build
```

Wire VS Code to the REPL wrapper (the value is machine-specific, so the file is git-ignored):

```sh
cp .vscode/settings.example.json .vscode/settings.json
# then edit tidalcycles.ghciPath to <this repo>/boot/ghci
```

Verify that Tidal is importable (the dependency is project-scoped, so use `cabal repl` rather than plain `ghci`):

```sh
cabal repl
# > import Sound.Tidal.Context
# > tidal_version
```

## 🎛️ Usage

1. Launch SuperCollider, open `boot/superdirt_startup.scd` in the SC IDE and evaluate it (or have the user `startup.scd` load it); wait until the post window reports `SuperDirt: listening to Tidal on port 57120`.
2. Open a `.tidal` file under `patterns/` in VS Code.  
   The first evaluation boots Tidal through `boot/ghci` and `BootTidal.hs`.
3. Evaluate: `Shift+Enter` runs the current statement, `Ctrl+Enter` the blank-line-separated block under the cursor, and `Ctrl+Alt+H` hushes every channel.

Keep one artistic idea per `.tidal` file and iterate inside it, leaving earlier variants commented out for A/B comparison.  
Conventions for channels, mini-notation and comments are in [.claude/rules/tidal-patterns.md](./.claude/rules/tidal-patterns.md).

## 🔄 Maintenance

- New Tidal release (watch the [Codeberg releases](https://codeberg.org/uzu/tidal/releases)): run `cabal update && cabal build`.  
  If the solver keeps an old version, delete `dist-newstyle/` and build again.  
  Then diff the part of `BootTidal.hs` above the `-- Local additions` marker against the copy shipped with the new release.
- GHC upgrade via `ghcup`: re-run `cabal build`; the store is per GHC version, so the first build recompiles dependencies.
- SuperDirt update: bump the refspec in `boot/quarks.txt`, re-run the install procedure from [docs/setup.md](./docs/setup.md#4-superdirt) in the SC IDE and recompile, then diff `boot/superdirt_startup.scd` against the new upstream example.

## 🧭 Scope

In scope: Tidal patterns, Haskell helper modules, and the editor and audio setup that makes them playable.  
Parked until baseline Tidal fluency is reached: DAW integration (Logic, Ableton Live), visual live coding (Hydra), and audio rendering or mastering pipelines.

## 📚 References

TidalCycles upstream development moved from GitHub to Codeberg in mid-2025, and SuperDirt followed in late 2025; the archived GitHub repos remain readable but receive no updates.

- Tidal docs: <https://tidalcycles.org/>
- Tidal source and releases: <https://codeberg.org/uzu/tidal>
- SuperDirt: <https://codeberg.org/musikinformatik/SuperDirt>
- Strudel: <https://codeberg.org/uzu/strudel> (REPL at <https://strudel.cc/>)
- Uzu forum (formerly Tidal Club): <https://uzu.lurk.org/>
- SuperCollider: <https://supercollider.github.io/>
- GHCup: <https://www.haskell.org/ghcup/>

## 🤖 AI agents

Instructions for AI coding agents live in [AGENTS.md](./AGENTS.md), which [CLAUDE.md](./CLAUDE.md) imports.  
Path-scoped conventions for `.tidal` and `.hs` files are under [.claude/rules/](./.claude/rules/).

## 📄 License

Not yet licensed (MIT planned); to be decided before publishing.  
Patterns and Haskell snippets inside may incorporate ideas from the Tidal community — credit upstream when copying non-trivial work.
