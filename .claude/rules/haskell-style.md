---
paths:
  - "**/*.hs"
---

# Haskell Style for This Sandbox

Canonical Haskell rules for this repo;
[AGENTS.md](../../AGENTS.md) links here for agents that do not load path-scoped rules automatically.
These rules apply to `.hs` files only —
never run Ormolu or HLint on `.tidal` files, which are pattern fragments rather than Haskell modules, even though VS Code associates them with the `haskell` language mode.

## Auto-format After Writes

After creating or modifying any `.hs` file, run Ormolu in-place against the affected file(s):

```bash
ormolu --mode inplace path/to/File.hs
```

Ormolu must be installed standalone (`cabal install ormolu`); the Ormolu bundled inside HLS is reachable only via the editor's LSP, not the shell.
If `ormolu` is not on PATH, stop and tell the user — do not commit unformatted output.

If Ormolu reports a parse error, treat that as a real failure of the generated code: show the error, fix the source, then retry the format.
Do not skip the format step to move on.

## Linting

HLint (`cabal install hlint`) surfaces idiom suggestions.
HLS shows them inline in the editor; from the shell, `hlint path/to/File.hs` lists them.
Address HLint suggestions unless doing so harms live-coding readability (e.g. an eta-reduction that hides the pattern-channel slot).

## Learning-Mode Comments

The user is learning Haskell alongside Tidal.

When generating non-trivial Haskell, add one-line explanatory comments for:

- Type-class machinery (`Functor`, `Applicative`, `Monad`).
- Operator sections and point-free constructions.
- Idioms a Python/Go/Java engineer would not immediately recognize (`<$>`, `<*>`, `>>=`, `&`, `flip`, `on`).

Skip trivial syntax (`let` / `where`, basic function application).
