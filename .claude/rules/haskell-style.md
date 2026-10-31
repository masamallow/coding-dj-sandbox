---
paths:
  - "**/*.hs"
---

# Haskell Style for This Sandbox

Rules that matter only when writing `.hs` files;
[AGENTS.md](../../AGENTS.md) links here for agents that do not load path-scoped rules automatically.  
Repository-wide rules stay in AGENTS.md: module registration in the cabal file, the `-- Local additions` marker in `BootTidal.hs`, and how upstream versions are tracked.

## Scope

These rules apply to the Haskell modules under `src/` only.  
Never run Ormolu or HLint on `.tidal` files: they are pattern fragments, not Haskell modules, even though VS Code opens them in the `haskell` language mode.  
`BootTidal.hs` is also exempt: it is a GHCi script (it contains `:set` commands), not a Haskell module, so Ormolu cannot parse it.

## Language Extensions

Do not add `LANGUAGE` pragmas for extensions that the `default-language` in `coding-dj-sandbox.cabal` already enables;
check the cabal file instead of assuming a particular language edition.

## Auto-format After Writes

After creating or modifying any `.hs` file, run Ormolu in-place against the affected file(s):

```bash
ormolu --mode inplace path/to/File.hs
```

This needs a standalone Ormolu (`cabal install ormolu`); the Ormolu compiled into HLS is reachable only through the editor.  
`.vscode/settings.example.json` points HLS at the same executable (`haskell.plugin.ormolu.config.external`), so the editor and the shell format identically.  
If `ormolu` is not on PATH, stop and tell the user — do not commit unformatted output.

If Ormolu reports a parse error, treat that as a real failure of the generated code: show the error, fix the source, then retry the format.  
Do not skip the format step to move on.

## Linting

HLint (`cabal install hlint`) surfaces idiom suggestions; HLS shows them inline, and `hlint path/to/File.hs` lists them from the shell.  
Address them unless doing so harms live-coding readability (e.g. an eta-reduction that hides which argument is the pattern being played).  
A hint that is rejected every time belongs in an `.hlint.yaml` ignore rule, not in this file.

## Learning-Mode Comments

The user is learning Haskell alongside Tidal.

When generating non-trivial Haskell, add one-line explanatory comments for:

- Type-class machinery (`Functor`, `Applicative`, `Monad`).
- Operator sections and point-free constructions.
- Idioms a Python/Go/Java engineer would not immediately recognize (`<$>`, `<*>`, `>>=`, `&`, `flip`, `on`, `where` clauses).
