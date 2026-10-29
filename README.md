# Coding DJ Sandbox

Personal sandbox for learning **Coding DJ** (live-coding music) on macOS, using TidalCycles + SuperCollider + VS Code as the primary stack.
Haskell is a parallel learning track via the Tidal Haskell library.

## Layout

```text
.
├── patterns/                 # *.tidal files (live-coding patterns)
├── src/*.hs                  # (optional) helper Haskell modules
├── boot/ghci                 # REPL wrapper (cabal repl) spawned by the VS Code extension
├── docs/setup.md             # environment setup guide
├── BootTidal.hs              # Tidal boot script piped into the REPL
├── coding-dj-sandbox.cabal   # minimal cabal package depending on tidal
├── .vscode/settings.example.json   # template for the git-ignored .vscode/settings.json
└── README.md
```

`BootTidal.hs` is a verbatim copy of the boot file shipped with the current Tidal release;
the VS Code extension auto-detects it at the workspace root (no extra setting needed), and it is the place for local customization.
Helper modules (e.g. `MyHelpers.hs`) live at `src/` and are registered under `exposed-modules` in `coding-dj-sandbox.cabal` so both the REPL and HLS see them.
VS Code wiring: copy `.vscode/settings.example.json` to the git-ignored `.vscode/settings.json` and point `tidalcycles.ghciPath` at `boot/ghci`
(see [docs/setup.md](./docs/setup.md#7-vs-code-wiring)).

## Prerequisites

- macOS (tested on Apple Silicon).
- Haskell toolchain via [GHCup]: GHC and cabal (versions are managed by GHCup, not pinned in this repo).
- [SuperCollider] with `sc3-plugins` and `SuperDirt` Quark.
- VS Code with two extensions:
  - [`tidalcycles.vscode-tidalcycles`][vscode-tidal] for `.tidal` evaluation.
  - [`haskell.haskell`][vscode-haskell] for the Haskell Language Server,
    which provides the **Ormolu** formatter and surfaces **HLint** diagnostics.
    Formatting and linting policy is delegated to these tools (see `.claude/rules/haskell-style.md`).
- HLint CLI (optional, useful outside HLS): `cabal install hlint`.

> [!NOTE]
> The Tidal extension sees little upstream activity: as of 2026-10 it has had no release since 2025-05, and the official Tidal tutorial assumes the Pulsar editor.
> It works with the current Tidal release, but check the [Marketplace page][vscode-tidal] and the [editor docs](https://tidalcycles.org/docs/getting-started/editor/) before relying on newer features.

[GHCup]: https://www.haskell.org/ghcup/
[SuperCollider]: https://supercollider.github.io/
[vscode-tidal]: https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles
[vscode-haskell]: https://marketplace.visualstudio.com/items?itemName=haskell.haskell

See [docs/setup.md](./docs/setup.md) for the full environment setup procedure.

## Quick verification

```sh
ghc --version
cabal --version

# build / update the Tidal lib (repo-scoped, from the repo root)
cabal update
cabal build

# verify import (the dependency is project-scoped, so use cabal repl)
cabal repl
# > import Sound.Tidal.Context
# > tidal_version
```

If an upgrade breaks the build or the import,
delete `dist-newstyle/` and run `cabal build` again.

## Upstream notes

TidalCycles upstream development moved from GitHub to Codeberg in mid-2025. Use these as the active sources:

- TidalCycles: <https://codeberg.org/uzu/tidal>
- Strudel: <https://codeberg.org/uzu/strudel>

The archived GitHub repos remain readable but receive no updates.

## License

This is a personal sandbox; no license file.
Patterns and Haskell snippets inside may incorporate ideas from the Tidal community — credit upstream when copying non-trivial work.
