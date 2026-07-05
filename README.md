# Coding DJ Sandbox

Personal sandbox for learning **Coding DJ** (live-coding music) on macOS, using TidalCycles + SuperCollider + VS Code as the primary stack.
Haskell is a parallel learning track via the Tidal Haskell library.

## Layout

```text
.
├── patterns/                 # *.tidal files (live-coding patterns)
├── BootTidal.hs              # (optional) custom Tidal boot file at root
├── *.hs                      # (optional) helper Haskell modules at root
└── README.md
```

`BootTidal.hs` is **not** included by default;
the Tidal package's bundled boot file is used until you create one here and flip `tidalcycles.useBootFileInCurrentDirectory` to `true` in `.vscode/settings.json`.
Helper modules (e.g. `MyHelpers.hs`) live at the workspace root so `BootTidal.hs` can `import` them without configuring `ghci` search paths.

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

[GHCup]: https://www.haskell.org/ghcup/
[SuperCollider]: https://supercollider.github.io/
[vscode-tidal]: https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles
[vscode-haskell]: https://marketplace.visualstudio.com/items?itemName=haskell.haskell

TODO: Detailed setup steps are coming soon.

## Quick verification

```sh
ghc --version
cabal --version

# install / update Tidal lib
cabal update
cabal install tidal --lib

# verify import (tidal is registered in the default GHC environment)
ghci
# > import Sound.Tidal.Context
# > tidal_version
```

If an upgrade breaks the import,
reset the default GHC environment file (`~/.ghc/*/environments/default`) and re-run the install.

## Upstream notes

TidalCycles upstream development moved from GitHub to Codeberg in mid-2025. Use these as the active sources:

- TidalCycles: <https://codeberg.org/uzu/tidal>
- Strudel: <https://codeberg.org/uzu/strudel>

The archived GitHub repos remain readable but receive no updates.

## License

This is a personal sandbox; no license file.
Patterns and Haskell snippets inside may incorporate ideas from the Tidal community — credit upstream when copying non-trivial work.
