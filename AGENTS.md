# AGENTS Instructions

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
  (low upstream activity: as of 2026-10 no release since 2025-05, and the official tutorials assume Pulsar;
  do not assume features beyond what the installed version documents).
- **Haskell toolchain**: GHC and cabal via GHCup (`ghc --version` / `cabal --version` show the active toolchain)
- **OS**: macOS on Apple Silicon (M3 Pro, 36 GB)

Strudel (https://strudel.cc) is the popular browser-based alternative used by several reference performers,
but this repository deliberately standardizes on TidalCycles to gain Haskell exposure alongside live-coding practice.
**Do not propose migrating to Strudel** unless the user explicitly opens that direction.

## Important Project Status (2025+)

TidalCycles' upstream development moved from GitHub to **Codeberg** in mid-2025.
The GitHub `tidalcycles/Tidal` and `tidalcycles/strudel` repos are archived (read-only).

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
- `BootTidal.hs` (workspace root, committed) — Tidal boot script piped into the REPL;
  a verbatim copy of the file shipped with the current Tidal release, customizable locally.
  The VS Code extension resolves the boot file as:
  `tidalcycles.bootTidalPath` setting → `BootTidal.hs` at the workspace root (auto-detected) → `ghc-pkg` fallback (which cannot see store-based cabal builds — keep the root file).
- `boot/ghci` — Wrapper that the `tidalcycles.ghciPath` setting points at;
  it cds to the repo root and launches `cabal repl`, because the extension spawns the REPL without setting a working directory.
  It must be named `ghci`: the extension treats the setting as the location of a `ghci` binary and appends `/ghci` to any other path.
- `.vscode/settings.example.json` — Template for the git-ignored `.vscode/settings.json`;
  it carries the shared settings (including the `*.tidal` → `haskell` association the extension needs to activate) plus a placeholder `tidalcycles.ghciPath`, which is machine-specific.
- `src/<Module>.hs` — Additional Haskell helper modules, imported from `BootTidal.hs` (e.g. `src/MyHelpers.hs`).
  Register each one under `exposed-modules` in `coding-dj-sandbox.cabal` so the REPL and HLS both see them;
  until the first module exists, `cabal repl` prints `Warning: No exposed modules`, which is expected.
- `docs/setup.md` — Environment setup guide.

## File Conventions

- Tidal patterns use the `.tidal` extension (associated with the VS Code extension and used by tooling for syntax handling).
- `.tidal` files live under `patterns/`. One artistic idea per file.
  Iterate inside the file, including through commented-out variants, rather than spawning new files for tiny tweaks.
- Haskell utility modules use `.hs` and live under `src/`, the cabal library's `hs-source-dirs`.
  Register them under `exposed-modules` in `coding-dj-sandbox.cabal`;
  `cabal repl` then loads them, so `BootTidal.hs` can import them without `-i` flags.

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

SuperCollider startup, the SuperDirt boot block, and the VS Code evaluate flow (`Shift+Enter` one statement, `Ctrl+Enter` multiple lines, `Ctrl+Alt+H` hush) are GUI / IDE workflows.
Do not script them or recommend automating them in CI.

## Workflow Rules

- Do not hardcode upstream or toolchain versions in committed docs;
  point to the source that manages them (Codeberg releases, Tidal release notes, `ghc --version` / `cabal --version`) instead.
- Before suggesting an installation or upgrade step that touches SuperDirt Quarks,
  check whether the current Tidal release notes on Codeberg require a particular SuperDirt version.
- When suggesting Haskell that goes into `BootTidal.hs` or imported helper modules under `src/`, target the GHC that GHCup has installed (check `ghc --version`).
  Do not assume language features from newer GHC releases unless explicitly approved.
- Never assume the user wants Strudel output, even if examples online use Strudel syntax.
  Translate to TidalCycles syntax when the source is Strudel.
- For Tidal-specific documentation lookups, prefer direct web fetches from <https://tidalcycles.org> and <https://codeberg.org/uzu/tidal> over Context7.
  Context7 indexes from GitHub; the active Tidal sources are on Codeberg and may be missing or outdated in the Context7 index.
  Use Context7 freely for non-Tidal libraries (general Haskell ecosystem packages such as `text`, `aeson`, `mtl`, etc.).

## Style Rules

Path-scoped conventions live under [.claude/rules/](./.claude/rules/):

- [tidal-patterns.md](./.claude/rules/tidal-patterns.md) — follow when generating or editing `.tidal` files (channel layout, mini-notation first, in-file comments).
- [haskell-style.md](./.claude/rules/haskell-style.md) — follow when generating or editing `.hs` files (Ormolu after writes, HLint, learning-mode comments).

Claude Code loads these automatically when matching files are touched;
other agents must read them before editing such files.

## Out of Scope

- DAW integration (Logic, Ableton Live) is parked until baseline Tidal fluency is reached.
- Visual live coding (Hydra) is parked.
- Strudel-based work is parked unless the user explicitly asks for it.
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
