# AGENTS Instructions

## Purpose

A sandbox for learning live-coding music ("Coding DJ") on macOS with **TidalCycles**.  
The user picks up Haskell along the way, through Tidal's Haskell foundation, but Haskell is not a goal of its own:
explain it where a pattern or helper needs it, and do not steer the work toward Haskell exercises.

Assume strong general programming fundamentals; do not assume Haskell or DSP knowledge.

## Primary Stack

- **Live coding language**: TidalCycles (Haskell DSL for pattern-oriented music)
- **Audio engine**: SuperCollider + SuperDirt (`sclang` / `scsynth`)
- **Editor**: VS Code with the `tidalcycles.vscode-tidalcycles` extension
  (low upstream activity: as of 2026-10 no release since 2025-05, and the official tutorials assume Pulsar;
  do not assume features beyond what the installed version documents).
- **Haskell toolchain**: GHC and cabal via GHCup (`ghc --version` / `cabal --version` show the active toolchain)
- **OS**: macOS on Apple Silicon (M3 Pro, 36 GB)

Strudel (https://strudel.cc) is Tidal's browser-based sibling and a handy way to play without the SuperCollider stack.  
Conversations default to TidalCycles: write and explain patterns in Tidal unless the user asks for Strudel.  
Translating in either direction (Strudel → Tidal, Tidal → Strudel) is an ordinary request when it comes up.

## Important Project Status (2025+)

TidalCycles' upstream development moved from GitHub to **Codeberg** in mid-2025, and SuperDirt followed in late 2025.  
The GitHub `tidalcycles/Tidal`, `tidalcycles/strudel` and `musikinformatik/SuperDirt` repos are archived (read-only).

Active sources:
- Tidal: <https://codeberg.org/uzu/tidal>
- Strudel: <https://codeberg.org/uzu/strudel>
- SuperDirt: <https://codeberg.org/musikinformatik/SuperDirt>
- Current Tidal release: check <https://codeberg.org/uzu/tidal/releases> (also published to Hackage);
  do not record release versions here — they go stale.

When researching Tidal behavior or filing/searching issues, prefer Codeberg over the archived GitHub repos.  
Older blog posts and tutorials may still link to GitHub; treat those as informational, not the source of truth.

## Repository Layout

- `patterns/` — `.tidal` files. One file per piece, experiment, or exercise.
- `coding-dj-sandbox.cabal` (workspace root) — Minimal cabal package that depends on `tidal`,
  keeping the library repo-scoped (built into `dist-newstyle/` and the shared cabal store) instead of a user-global GHC environment.
- `BootTidal.hs` (workspace root, committed) — Tidal boot script piped into the REPL.  
  Everything above its trailing `-- Local additions` marker is a verbatim copy of the file shipped with the current Tidal release;
  local customization (aliases, latency, imports from `src/`) goes below the marker, so an upgrade only has to diff the part above it.  
  The VS Code extension resolves the boot file as:
  `tidalcycles.bootTidalPath` setting → `BootTidal.hs` at the workspace root (auto-detected) → `ghc-pkg` fallback (which cannot see store-based cabal builds — keep the root file).
- `boot/ghci` — Wrapper that the `tidalcycles.ghciPath` setting points at;
  it cds to the repo root and launches `cabal repl`, because the extension spawns the REPL without setting a working directory.  
  It must be named `ghci`: the extension treats the setting as the location of a `ghci` binary and appends `/ghci` to any other path.
- `boot/superdirt_startup.scd` — SuperCollider startup file for the SuperDirt side: boots the server and starts SuperDirt with this repository's settings.  
  It is adapted from the example shipped with the SuperDirt quark; lines marked `local:` are the deviations, so an upgrade only has to diff against the new example.  
  It is evaluated in the SuperCollider IDE, or run on launch by a `load("<absolute path>")` line in the user's `startup.scd` (that line stays outside the repo).
- `boot/quarks.txt` — The SuperCollider Quarks this setup needs (SuperDirt pinned to a release tag, plus its dependencies), in the `localPath=url[@refspec]` format that `Quarks.save` writes and `Quarks.load` reads.  
  The file allows no comments or blank lines; its `~/Library/Application Support/SuperCollider/...` entries are SuperCollider's fixed per-user quark folder, not a location of this repo.
- `boot/superdirt_local.example.scd` — Template for the git-ignored `boot/superdirt_local.scd`, which the startup file loads before booting; each line sets one key in `~dirtLocal` (audio device, channel counts, orbit count, latency, personal sample folders, an `onStart` hook) and overrides the tracked default.  
  Project-level defaults change in `boot/superdirt_startup.scd`; machine- or session-level values change only in the local file.
- `.vscode/settings.example.json` — Template for the git-ignored `.vscode/settings.json`;
  it carries the shared settings (including the `*.tidal` → `haskell` association the extension needs to activate) plus a placeholder `tidalcycles.ghciPath`, which is machine-specific.
- `hie.yaml` (workspace root) — hie-bios config for HLS: `src/` is loaded through cabal, while `patterns/` and `BootTidal.hs` get a `none` cradle so HLS ignores them instead of reporting errors.
- `src/<Module>.hs` — Additional Haskell helper modules, imported from `BootTidal.hs` (e.g. `src/MyHelpers.hs`).  
  Register each one under `exposed-modules` in `coding-dj-sandbox.cabal` so the REPL and HLS both see them;
  until the first module exists, `cabal repl` prints `Warning: No exposed modules`, which is expected.
- `docs/setup.md` — Environment setup guide.

## File Conventions

- Tidal patterns use the `.tidal` extension.  
  VS Code maps `*.tidal` to the `haskell` language via `.vscode/settings.json`; that mapping is what activates the Tidal extension and provides highlighting, while the extension's keybindings are enabled by the `.tidal` extension itself.
- `.tidal` files live under `patterns/`. One artistic idea per file.  
  Iterate inside the file, including through commented-out variants, rather than spawning new files for tiny tweaks.
- Haskell utility modules use `.hs` and live under `src/`, the cabal library's `hs-source-dirs`.  
  Register them under `exposed-modules` in `coding-dj-sandbox.cabal`;
  `cabal repl` then loads them, so `BootTidal.hs` can import them without `-i` flags.
- SuperCollider files use `.scd` and live under `boot/`, which holds the start-up pieces of both engines.  
  Keep `boot/superdirt_startup.scd` close to the upstream example and mark every deviation with a `local:` comment.

## Common Commands

Update the Tidal Haskell library (after a Codeberg release), from the repo root:

```bash
cabal update
cabal build
```

If an upgrade leaves the build or `import Sound.Tidal.Context` broken,
delete `dist-newstyle/` and run `cabal build` again.

Verify Tidal is importable (the dependency is repo-scoped, so use `cabal repl` from the repo root rather than plain `ghci`):

```bash
cabal repl
# at the prompt:
# > import Sound.Tidal.Context
# > tidal_version
```

Verify the Haskell toolchain (versions are managed by GHCup, not pinned in this repo):

```bash
ghc --version
cabal --version
```

Install the SuperCollider Quarks (in the SuperCollider IDE, then Language > Recompile Class Library); `docs/setup.md` step 4 has the full procedures:

```supercollider
// A. SuperCollider dedicated to this setup: load the committed set.
//    CAUTION: this first removes every installed Quark.
Quarks.load("/absolute/path/to/coding-dj-sandbox/boot/quarks.txt")
// B. SuperCollider shared with other projects: install SuperDirt alone,
//    with the refspec taken from boot/quarks.txt; its dependencies follow.
Quarks.install("SuperDirt", "<refspec from boot/quarks.txt>")
```

Never suggest procedure A without confirming that the machine's SuperCollider serves only this repository.  
After changing the installed set by other means, regenerate the file with `Quarks.save("/absolute/path/to/coding-dj-sandbox/boot/quarks.txt")` and commit the result.

SuperCollider startup (evaluating `boot/superdirt_startup.scd` in the SC IDE) and the VS Code evaluate flow (`Shift+Enter` one statement, `Ctrl+Enter` multiple lines, `Ctrl+Alt+H` hush) are GUI / IDE workflows:
never drive `sclang`, `scsynth` or the editor from shell scripts, mise tasks or CI.  
SuperCollider's own startup mechanism is configuration, not automation: a `load(...)` line in the user's `startup.scd` that points at `boot/superdirt_startup.scd` is fine.

## Workflow Rules

- Do not hardcode upstream or toolchain versions in committed docs;
  point to the source that manages them (Codeberg releases, Tidal release notes, `ghc --version` / `cabal --version`) instead.  
  The dependency bounds in `coding-dj-sandbox.cabal` (`base`, `tidal`) and the SuperDirt refspec in `boot/quarks.txt` are the exceptions: they declare compatibility, and the cabal comments explain each bound.
- Before bumping the SuperDirt refspec in `boot/quarks.txt` or suggesting any step that touches SuperDirt Quarks,
  check the current Tidal release notes on Codeberg and the minimum SuperDirt version Tidal prints while it waits for SuperDirt at stream start (a line like `Waiting for SuperDirt (v.x.y.z or higher)`, shown only when Tidal boots before SuperDirt is up);
  the release notes alone may not state it.  
  After a bump, re-run the install procedure (`Quarks.load` on a dedicated SuperCollider, `Quarks.install` with the new refspec otherwise), recompile, and diff `boot/superdirt_startup.scd` against the new upstream example.
- sc3-plugins is a per-machine install into SuperCollider's `Extensions/` folder (see `docs/setup.md`); it cannot be declared in `.scd` files or in `boot/quarks.txt`.  
  SuperDirt treats it as optional and warns `sc3plugins are necessary and missing` when it is absent.
- When suggesting Haskell that goes into `BootTidal.hs` or imported helper modules under `src/`, target the GHC that GHCup has installed (check `ghc --version`).  
  Do not assume language features from newer GHC releases unless explicitly approved.  
  The cabal library's `default-language` already turns on a set of extensions in `src/` modules; do not add `LANGUAGE` pragmas for those (check `coding-dj-sandbox.cabal` for the edition in use).
- Examples found online are often in Strudel syntax; translate them to TidalCycles unless the user asked for Strudel.
- Machine-specific values (absolute paths, `~/...` paths of this repo, hostnames) never go into tracked files.  
  They belong in the git-ignored `.vscode/settings.json` or `boot/superdirt_local.scd`, in VS Code user settings, or in the user's SuperCollider `startup.scd`; tracked files carry placeholders (see `.vscode/settings.example.json` and `boot/superdirt_local.example.scd`).  
  The `~/Library/Application Support/SuperCollider/...` entries in `boot/quarks.txt` are not machine-specific: that is SuperCollider's fixed per-user quark folder, written by `Quarks.save`.
- HLS diagnostics on `.tidal` files or `BootTidal.hs` are noise, not bugs: those files are not Haskell modules, and `hie.yaml` tells HLS to ignore them.  
  Do not rewrite a pattern or the boot file to satisfy HLS.
- For Tidal-specific documentation lookups, prefer direct web fetches from <https://tidalcycles.org> and <https://codeberg.org/uzu/tidal> over Context7.  
  Context7 indexes from GitHub; the active Tidal sources are on Codeberg and may be missing or outdated in the Context7 index.  
  Use Context7 freely for non-Tidal libraries (general Haskell ecosystem packages such as `text`, `aeson`, `mtl`, etc.).
- When a step deviates from the upstream documentation because the documented way did not work, or does not hold, for the versions this repository assumes, record it next to the step in `docs/setup.md` as a `NOTE` alert:
  what upstream says (a short quote and a link pinned to a tag or commit), what is done instead, and the date it was checked.  
  Upstream pages get rewritten; the pinned link and the date keep the note verifiable later.
- Quote program output as an example of its shape, not as an exact expectation: messages change between versions.  
  Write what the reader should see (e.g. that the post window reports SuperDirt listening on port 57120) with a sample line, and do not treat a wording difference between a message and the docs as something to fix on either side.

## Style Rules

Path-scoped conventions live under [.claude/rules/](./.claude/rules/):

- [tidal-patterns.md](./.claude/rules/tidal-patterns.md) — follow when generating or editing `.tidal` files (pattern layout, mini-notation first, one statement per block).
- [haskell-style.md](./.claude/rules/haskell-style.md) — follow when generating or editing `.hs` files (Ormolu after writes, HLint, learning-mode comments).

Claude Code loads these automatically when matching files are touched;
other agents must read them before editing such files.

## Out of Scope

- DAW integration (Logic, Ableton Live) is parked until baseline Tidal fluency is reached.
- Visual live coding (Hydra) is parked.
- Audio rendering / mastering pipelines are parked.

## Key References

- Tidal docs: <https://tidalcycles.org/>
- Tidal source (active): <https://codeberg.org/uzu/tidal>
- Uzu forum (formerly Tidal Club; covers Tidal and Strudel): <https://uzu.lurk.org/>
- Strudel REPL: <https://strudel.cc/>
- Strudel source (active): <https://codeberg.org/uzu/strudel>
- SuperCollider: <https://supercollider.github.io/>
- SuperDirt (active): <https://codeberg.org/musikinformatik/SuperDirt> (the GitHub repo is archived)
- VS Code extension: <https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles>
- GHCup (Haskell toolchain): <https://www.haskell.org/ghcup/>
