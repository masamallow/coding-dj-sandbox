---
paths:
  - "**/*.hs"
  - "boot/**/*"
---

# Haskell Style for This Sandbox

These rules apply when editing `.hs` files (custom `BootTidal.hs`, helper modules, experiments).

## Toolchain Compatibility

- Target **GHC 9.6.x** (currently 9.6.7).
  Do not propose features that require 9.8 or later (`ghc2024` extensions, `ImportedPaths`, etc.) without flagging the bump explicitly.
- Use cabal `v2-style` commands (`cabal build`, `cabal install --lib`).
  Avoid `v1-` commands; they are legacy.
- Tidal 1.10+ assumes `network-3.1.x` and `text < 2.1`.
  If a proposed dependency conflicts, raise that explicitly rather than auto-resolving with `--allow-newer`.

## Style Defaults

- 2-space indentation. No tabs.
- Module names match the file path (`Boot.Sandbox` lives at `boot/Boot/Sandbox.hs`).
- Import ordering: standard libraries, then third-party, then local.
  Within each group, alphabetical. One blank line between groups.
- Prefer explicit imports over open imports for non-Tidal modules.
  For `Sound.Tidal.Context`, the open import is idiomatic; keep it open.

## Tidal-Specific Practices

- Custom helpers in `BootTidal.hs` should follow the Tidal naming idiom: short, lowercase, no underscores (`bdroll`, not `bd_roll`).
- Keep boot file additions self-contained.
  If a helper depends on extra packages, put it in a separate module under `boot/` and `import` it from `BootTidal.hs`.
- When defining new pattern combinators, give them a type signature (`Pattern a -> Pattern a` etc.).
  Tidal's type machinery is informative and worth practicing.

## Learning-Mode Comments

The user is learning Haskell alongside Tidal.

When generating non-trivial Haskell code, include short explanatory comments for:

- Type-class machinery (Functor, Applicative, Monad usage).
- Operator sections and point-free constructions.
- Anything that exercises an idiom a Python/Go/Java engineer would not immediately recognize (`<$>`, `<*>`, `>>=`, `&`, `flip`, `on`).

Keep comments concise — one line per construct is usually enough.
Do not add comments explaining trivial syntax (basic function application, `let` / `where`).
