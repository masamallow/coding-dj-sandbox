# Environment Setup (macOS)

Step-by-step setup for this sandbox on macOS (Apple Silicon), from a fresh machine to playing `.tidal` patterns from VS Code.

Conventions used below:

- Steps marked `[GUI]` are performed manually in the SuperCollider IDE or VS Code.  
  Per [AGENTS.md](../AGENTS.md), these flows are never driven from shell scripts, mise tasks or CI; SuperCollider's own `startup.scd` mechanism (step 5) is the one sanctioned way to run them on launch.
- No tool versions are pinned in this document.  
  Check the sources that manage them instead:
  [Tidal releases](https://codeberg.org/uzu/tidal/releases),
  [SuperDirt](https://codeberg.org/musikinformatik/SuperDirt),
  [sc3-plugins releases](https://github.com/supercollider/sc3-plugins/releases),
  and `ghc --version` / `cabal --version` for the GHCup toolchain.

## How the pieces fit

SuperCollider (with the SuperDirt quark) is the audio engine; it listens for OSC messages.  
The `tidal` Haskell library runs inside a GHCi REPL started by the VS Code extension and sends those messages when you evaluate patterns.

This repository is a minimal cabal package ([coding-dj-sandbox.cabal](../coding-dj-sandbox.cabal)) whose job is to depend on `tidal` and to compile helper modules under `src/`.  
With cabal's Nix-style local builds, the dependency stays repo-scoped:
the build plan lives in `dist-newstyle/` (gitignored) and compiled packages live in the shared cabal store (`~/.cabal/store`).  
Nothing is written to the user-global GHC environment, so other Haskell projects are unaffected.

The SuperCollider side has two committed files of its own:
[boot/quarks.txt](../boot/quarks.txt) lists the Quarks (SuperDirt pinned to a release tag, plus its dependencies) and [boot/superdirt_startup.scd](../boot/superdirt_startup.scd) configures and starts SuperDirt.  
SuperCollider has no per-project class library, so the application, sc3-plugins and the Quark clones themselves stay per-user; the steps below that install them run once per machine.

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
`tidalcycles.vscode-tidalcycles`, `haskell.haskell`, and `haskell.language-haskell`
(the syntax extension formerly published as `justusadam.language-haskell`; uninstall the old one if both are installed).

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

sc3-plugins is a per-machine install; nothing in the repository can declare or load it.  
SuperDirt treats it as optional: without it the post window warns `sc3plugins are necessary and missing` and the extra synths and effects that need it are skipped, while the core sounds still work.

## 4. SuperDirt

`[GUI]` In the SuperCollider IDE, install the Quarks listed in [boot/quarks.txt](../boot/quarks.txt) — SuperDirt pinned to a release tag, plus its dependencies Vowel and Dirt-Samples:

```supercollider
Quarks.load("/absolute/path/to/coding-dj-sandbox/boot/quarks.txt")
```

Then run Language > Recompile Class Library.  
`Quarks.load` first clears every installed Quark and then installs the listed set, which assumes this machine's SuperCollider is dedicated to this setup.  
The first run clones Dirt-Samples, a large sample library; give it several minutes and watch the post window.

Verify: Language > Quarks should list SuperDirt, Dirt-Samples and Vowel as installed, and the sample folders should be present (the SuperDirt README notes that the unpack sometimes fails silently):

```sh
ls "$HOME/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples" | head
```

The file format is the one `Quarks.save` writes (`localPath=url[@refspec]`, no comments or blank lines); after changing the installed set by any other means, regenerate it with `Quarks.save("/absolute/path/to/coding-dj-sandbox/boot/quarks.txt")` and commit the result.  
Upstream documents two other install forms, `include("SuperDirt")` (SuperDirt README; installs the head of the develop branch) and `Quarks.install("SuperDirt", "vX.Y.Z")` (tidalcycles.org macOS page); both work but bypass the pinned set.

The active SuperDirt repository is <https://codeberg.org/musikinformatik/SuperDirt>; the GitHub repository is archived.  
The Quarks directory points at the Codeberg repository; an install made before the move may still track the archived GitHub clone — check the source in the Quarks GUI before updating.  
Before bumping the pinned version, check whether the current Tidal release notes require a particular SuperDirt version and the minimum Tidal prints at stream start (`Waiting for SuperDirt (v.x.y.z or higher)`).

## 5. SuperDirt startup file

[boot/superdirt_startup.scd](../boot/superdirt_startup.scd) boots the server and starts SuperDirt with this repository's settings (buffer counts, two output channels, twelve orbits, port 57120).  
It is adapted from the example shipped with the SuperDirt quark (`downloaded-quarks/SuperDirt/superdirt_startup.scd`); lines marked `local:` are the deviations, so an upgrade only needs a diff against the new example.

`[GUI]` Open the file in the SuperCollider IDE, place the cursor inside the outer parentheses and press Cmd+Return.  
The post window should end with `SuperDirt: listening to Tidal on port 57120`.

To have SuperCollider do this on launch, open the user startup file (File > Open startup file) and add one line with the absolute path of this repository:

```supercollider
load("/absolute/path/to/coding-dj-sandbox/boot/superdirt_startup.scd");
```

That absolute path belongs in the per-user startup file, never in the repository.  
`SuperDirt.start` (one line, no file) starts SuperDirt with close to the same defaults and is the quickest way to tell a server problem from a problem in the startup file.

## 6. Tidal library (repo-scoped cabal build)

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

## 7. BootTidal.hs

[BootTidal.hs](../BootTidal.hs) at the repo root is the GHCi boot script the editor pipes into the REPL; it imports Tidal and starts the stream.  
Everything above its trailing `-- Local additions` marker is a verbatim copy of the file shipped with the current Tidal release, committed so the VS Code extension finds it deterministically:
the extension resolves the boot file as `tidalcycles.bootTidalPath` setting → workspace-root `BootTidal.hs` → a `ghc-pkg` fallback that cannot see store-based cabal builds.  
It is a GHCi script (note the `:set` lines), not a Haskell module, so Ormolu/HLint do not apply, and [hie.yaml](../hie.yaml) keeps the Haskell Language Server from loading it.  
Put local customization (aliases, latency, Link sync, imports from `src/`) below the marker, so an upgrade only has to diff the part above it.

## 8. VS Code wiring

The Tidal extension spawns the REPL through `/bin/sh` without setting a working directory, so on its own it cannot find this cabal project.  
[boot/ghci](../boot/ghci) fixes that: it puts the GHCup toolchain on PATH, changes to the repo root, and launches `cabal repl`.  
The wrapper must be named `ghci`: the extension treats `tidalcycles.ghciPath` as the location of a `ghci` binary and appends `/ghci` to any other path.

`.vscode/settings.json` is git-ignored because `tidalcycles.ghciPath` is machine-specific.  
Create it from the committed template and point `tidalcycles.ghciPath` at the wrapper (a leading `~` is expanded by the extension):

```sh
cp .vscode/settings.example.json .vscode/settings.json
# then edit tidalcycles.ghciPath to <this repo>/boot/ghci
```

The template also carries the `*.tidal` → `haskell` file association, which the extension needs: it activates only when a Haskell-language file is opened.  
When you change a setting that should apply on every machine, update the template as well.

Open this repository directly as the (first) workspace folder;
the extension resolves `BootTidal.hs` against the first workspace folder only.

> [!NOTE]
> The Tidal extension sees little upstream activity: as of 2026-10 it has had no release since 2025-05, and the official Tidal tutorial assumes the Pulsar editor.  
> It works with the current Tidal release, but check the [Marketplace page](https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles) and the [editor docs](https://tidalcycles.org/docs/getting-started/editor/) before relying on newer features.

Default keybindings of the extension:

- `Shift+Enter` — evaluate the current statement
- `Ctrl+Enter` — evaluate multiple lines
- `Ctrl+Alt+H` — hush (silence all channels)

[hie.yaml](../hie.yaml) tells the Haskell Language Server to load `src/` through cabal and to ignore `patterns/` and `BootTidal.hs`,
which VS Code opens in `haskell` mode but which are not Haskell modules.

## 9. Formatter and linter (Haskell side)

Required by [.claude/rules/haskell-style.md](../.claude/rules/haskell-style.md) when editing `.hs` files:

```sh
cabal install ormolu hlint
```

This compiles for a while and installs binaries into `~/.cabal/bin` (on PATH via GHCup's shell setup).  
When re-installing after an upgrade, add `--overwrite-policy=always`.

## 10. Smoke test

1. `[GUI]` In the SC IDE, evaluate [boot/superdirt_startup.scd](../boot/superdirt_startup.scd) (step 5) and wait until the post window reports `SuperDirt: listening to Tidal on port 57120`.
2. `[GUI]` In VS Code, open a `.tidal` file under `patterns/` and evaluate with `Shift+Enter`:

   ```haskell
   d1 $ sound "bd sn"
   ```

3. You should hear a kick/snare loop.  
   Silence it with `hush` (or `Ctrl+Alt+H`).

## 11. Maintenance

- New Tidal release (watch [Codeberg releases](https://codeberg.org/uzu/tidal/releases)):
  run `cabal update && cabal build` from the repo root.  
  If the solver keeps an old version, delete `dist-newstyle/` and build again.  
  Afterwards, diff the part of `BootTidal.hs` above the `-- Local additions` marker against the copy shipped with the new release and merge upstream changes.
- GHC upgrade (via `ghcup`): re-run `cabal build`; the store is per-GHC-version, so the first build recompiles dependencies.
- SuperDirt update: bump the refspec in `boot/quarks.txt` after checking the Tidal release notes and the `Waiting for SuperDirt (v.x.y.z or higher)` message, then `[GUI]` re-run `Quarks.load` and recompile (step 4).  
  Afterwards diff `boot/superdirt_startup.scd` against the new upstream example and commit both files.  
  Dirt-Samples and Vowel are unpinned and follow their default branches; `[GUI]` `Quarks.update("Dirt-Samples")` in the SC IDE pulls new samples.

## Troubleshooting

- No sound: confirm the startup file (or `SuperDirt.start`) ran in the SC IDE and the post window shows `SuperDirt: listening to Tidal on port 57120`; re-evaluate the pattern.
- REPL fails to boot from VS Code: check the TidalCycles output channel.  
  If `cabal` is not found, the wrapper's PATH prepend should cover it — confirm `tidalcycles.ghciPath` points at [boot/ghci](../boot/ghci) and the script is executable.  
  A `Not a directory` error means the setting points at a file not named `ghci`; the extension appends `/ghci` to it.
- `import Sound.Tidal.Context` fails in a terminal: run `cabal repl` from the repo root; plain `ghci` does not see project dependencies (by design).
- "cannot be opened" dialogs for sc3-plugins: run the `xattr` command from step 3 and recompile the class library.
- `sc3plugins are necessary and missing` in the post window: sc3-plugins is not installed or not compiled in (step 3); SuperDirt still runs, minus the synths and effects that need it.
- `Quarks.load` posts `Unreadable line` or a `Quark ... not found` error: `boot/quarks.txt` allows no comments or blank lines, and each line must be `localPath=url[@refspec]` as written by `Quarks.save`.
- First server boot may trigger a macOS microphone-permission prompt (the server opens input buses); allow or deny — playback works either way.
- Bluetooth headsets often fail with an input/output sample-rate mismatch; align both devices in Audio MIDI Setup or use the built-in output.
- HLS shows errors in `BootTidal.hs` or a `.tidal` file: `hie.yaml` should make HLS ignore both; check that the file falls under a `none` cradle there and restart the language server.

## Appendix: global install (upstream docs approach)

The upstream Tidal docs install the library user-globally instead.  
The macOS page uses `cabal v1-install tidal` (or the `tidal-bootstrap` script, which runs the same command); the Linux page uses `cabal install tidal --lib`:

```sh
cabal update
cabal v1-install tidal
```

Either form registers `tidal` where every plain `ghci` picks it up (the v1 user package database, or a user-global GHC environment file under `~/.ghc/<platform>/environments/`), with no wrapper or project file needed.  
It is simpler, but it leaks into all other Haskell work on the machine, and repeated `--lib` installs can leave the environment file inconsistent (recovery: delete it and re-run a single install listing all needed libraries).  
This repo intentionally uses the cabal-project approach above instead.
