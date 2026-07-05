# Environment Setup (macOS)

Step-by-step setup for this sandbox on macOS (Apple Silicon), from a fresh machine to playing `.tidal` patterns from VS Code.

Conventions used below:

- Steps marked `[GUI]` are performed manually in the SuperCollider IDE or VS Code.
  Per [AGENTS.md](../AGENTS.md), these flows are never scripted or automated.
- No tool versions are pinned in this document.
  Check the sources that manage them instead:
  [Tidal releases](https://codeberg.org/uzu/tidal/releases),
  [SuperDirt](https://codeberg.org/musikinformatik/SuperDirt),
  [sc3-plugins releases](https://github.com/supercollider/sc3-plugins/releases),
  and `ghc --version` / `cabal --version` for the GHCup toolchain.

## How the pieces fit

SuperCollider (with the SuperDirt quark) is the audio engine; it listens for OSC messages.
The `tidal` Haskell library runs inside a GHCi REPL started by the VS Code extension and sends those messages when you evaluate patterns.

This repository is a minimal cabal package ([coding-dj-sandbox.cabal](../coding-dj-sandbox.cabal)) whose only job is to depend on `tidal`.
With cabal's Nix-style local builds, the dependency stays repo-scoped:
the build plan lives in `dist-newstyle/` (gitignored) and compiled packages live in the shared cabal store (`~/.cabal/store`).
Nothing is written to the user-global GHC environment, so other Haskell projects are unaffected.

GHC and cabal themselves are managed by [GHCup](https://www.haskell.org/ghcup/), the de-facto Haskell toolchain manager.
mise is deliberately not used for Haskell: its registry has no entries for GHC or GHCup.

## 1. Prerequisites

Verify the Haskell toolchain and supporting tools:

```sh
ghcup list -c installed   # GHC (set), cabal, and optionally HLS present
ghc --version
cabal --version
git --version
brew --version
```

Cross-check the GHC version against the CI-tested GHC versions listed in the current [Tidal release notes](https://codeberg.org/uzu/tidal/releases) before building.

VS Code should have the extensions recommended by [.vscode/extensions.json](../.vscode/extensions.json):
`tidalcycles.vscode-tidalcycles`, `haskell.haskell`, and `justusadam.language-haskell`.

## 2. SuperCollider

```sh
brew install --cask supercollider
```

`[GUI]` Launch SuperCollider.app once (approve the Gatekeeper dialog if shown).
The post window should report the class library compiled without errors, and `~/Library/Application Support/SuperCollider/` is created.

## 3. sc3-plugins (optional, recommended)

Many SuperDirt effect UGens need sc3-plugins.
Download the macOS universal build from the [releases page](https://github.com/supercollider/sc3-plugins/releases), unzip it, and copy the plugins folder into the SuperCollider extensions directory:

```sh
mkdir -p "$HOME/Library/Application Support/SuperCollider/Extensions"
cp -R <unzipped-plugins-folder> "$HOME/Library/Application Support/SuperCollider/Extensions/"
```

If macOS blocks the plugin binaries (browser downloads carry a quarantine attribute), clear it:

```sh
xattr -dr com.apple.quarantine "$HOME/Library/Application Support/SuperCollider/Extensions"
```

`[GUI]` In the SC IDE, run Language > Recompile Class Library and confirm the post window shows no errors.

## 4. SuperDirt

`[GUI]` In the SuperCollider IDE, evaluate:

```supercollider
include("SuperDirt")
```

This installs the SuperDirt quark plus the Dirt-Samples library and recompiles the class library.
The first run downloads a large sample set; give it several minutes and watch the post window.

The active SuperDirt repository is <https://codeberg.org/musikinformatik/SuperDirt>; the GitHub repository is archived.
The Quarks directory may still resolve the name to the archived GitHub mirror — that clone works, but confirm the source in the Quarks GUI if you ever need an update.
Before upgrading SuperDirt, check whether the current Tidal release notes require a particular version.

## 5. Tidal library (repo-scoped cabal build)

From the repo root:

```sh
cabal update
cabal build
```

Verify:

```sh
cabal repl
# at the prompt:
# > import Sound.Tidal.Context
# > tidal_version
```

Plain `ghci` outside `cabal repl` will not see `tidal` — that is by design; the dependency is scoped to this project.

## 6. BootTidal.hs

[BootTidal.hs](../BootTidal.hs) at the repo root is the GHCi boot script the editor pipes into the REPL; it imports Tidal and starts the stream.
It is a verbatim copy of the file shipped with the current Tidal release, committed so the VS Code extension finds it deterministically:
the extension resolves the boot file as `tidalcycles.bootTidalPath` setting → workspace-root `BootTidal.hs` → a `ghc-pkg` fallback that cannot see store-based cabal builds.
It is a GHCi script (note the `:set` lines), not a Haskell module, so Ormolu/HLint do not apply and Haskell Language Server diagnostics on it can be ignored.
Customize it here (aliases, latency, Link sync) as needed.

## 7. VS Code wiring

The Tidal extension spawns the REPL through `/bin/sh` without setting a working directory, so on its own it cannot find this cabal project.
[boot/tidal-repl.sh](../boot/tidal-repl.sh) fixes that: it puts the GHCup toolchain on PATH, changes to the repo root, and launches `cabal repl`.
[.vscode/settings.json](../.vscode/settings.json) points `tidalcycles.ghciPath` at that wrapper; adjust the path if the repo lives elsewhere on your machine.

Open this repository directly as the (first) workspace folder;
the extension resolves `BootTidal.hs` against the first workspace folder only.

Default keybindings of the extension:

- `Shift+Enter` — evaluate the current statement
- `Ctrl+Enter` — evaluate multiple lines
- `Ctrl+Alt+H` — hush (silence all channels)

## 8. Formatter and linter (Haskell side)

Required by [.claude/rules/haskell-style.md](../.claude/rules/haskell-style.md) when editing `.hs` files:

```sh
cabal install ormolu hlint
```

This compiles for a while and installs binaries into `~/.cabal/bin` (on PATH via GHCup's shell setup).
When re-installing after an upgrade, add `--overwrite-policy=always`.

## 9. Smoke test

1. `[GUI]` In the SC IDE, evaluate `SuperDirt.start` and wait until the post window reports SuperDirt is listening.
2. `[GUI]` In VS Code, open a `.tidal` file under `patterns/` and evaluate with `Shift+Enter`:

   ```haskell
   d1 $ sound "bd sn"
   ```

3. You should hear a kick/snare loop.
   Silence it with `hush` (or `Ctrl+Alt+H`).

## 10. Maintenance

- New Tidal release (watch [Codeberg releases](https://codeberg.org/uzu/tidal/releases)):
  run `cabal update && cabal build` from the repo root.
  If the solver keeps an old version, delete `dist-newstyle/` and build again.
  Afterwards, diff the repo's `BootTidal.hs` against the copy shipped with the new release and merge upstream changes.
- GHC upgrade (via `ghcup`): re-run `cabal build`; the store is per-GHC-version, so the first build recompiles dependencies.
- SuperDirt / Dirt-Samples updates: `[GUI]` via the Quarks GUI in the SC IDE.

## Troubleshooting

- No sound: confirm `SuperDirt.start` ran in the SC IDE and the post window shows it is listening; re-evaluate the pattern.
- REPL fails to boot from VS Code: check the TidalCycles output channel.
  If `cabal` is not found, the wrapper's PATH prepend should cover it — confirm `tidalcycles.ghciPath` points at [boot/tidal-repl.sh](../boot/tidal-repl.sh) and the script is executable.
- `import Sound.Tidal.Context` fails in a terminal: run `cabal repl` from the repo root; plain `ghci` does not see project dependencies (by design).
- "cannot be opened" dialogs for sc3-plugins: run the `xattr` command from step 3 and recompile the class library.
- First server boot may trigger a macOS microphone-permission prompt (the server opens input buses); allow or deny — playback works either way.
- Bluetooth headsets often fail with an input/output sample-rate mismatch; align both devices in Audio MIDI Setup or use the built-in output.
- HLS shows errors in `BootTidal.hs`: expected, since it is a GHCi script rather than a module; ignore them.

## Appendix: global install (upstream docs approach)

The upstream Tidal docs install the library user-globally instead:

```sh
cabal install tidal --lib
```

That writes a user-global GHC environment file (`~/.ghc/<platform>/environments/default`) that every plain `ghci` picks up, with no wrapper or project file needed.
It is simpler, but it leaks into all other Haskell work on the machine, and repeated `--lib` installs can leave the environment inconsistent (recovery: delete the default environment file and re-run a single install listing all needed libraries).
This repo intentionally uses the cabal-project approach above instead.
