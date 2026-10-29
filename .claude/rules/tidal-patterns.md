---
paths:
  - "**/*.tidal"
---

# Tidal Pattern Conventions

Canonical `.tidal` conventions for this repo;
[AGENTS.md](../../AGENTS.md) links here for agents that do not load path-scoped rules automatically.

## Channel Layout

By convention, `d1` carries drums (kick, snare, hats), `d2` carries bass, and `d3` and above carry harmonic and lead voices, FX, and vocal samples.  
`hush` silences all channels. Follow whatever layout is already in use when extending an existing file.

## Mini-notation First

When generating pattern code, prefer string mini-notation inside `sound "..."` and other `Pattern`-typed string parameters over verbose `cat` / `fastcat` / `stack` constructions,
unless a feature requires the explicit form.  
When a source example is in Strudel syntax, translate it to Tidal mini-notation unless the user asked for Strudel.

## One Block per Evaluation

The VS Code extension evaluates either the current line (`Shift+Enter`) or the contiguous block of non-blank lines around the cursor (`Ctrl+Enter`).  
Separate statements with blank lines so each block is exactly one statement, and never expect a file to run top-to-bottom.

## In-File Comments

Comments in `.tidal` files use `--`. Use them to label sections (intro, build, drop) and to record what changed during live iteration.  
When producing variants of a pattern, keep prior versions commented out for A/B comparison instead of deleting them.

## Editor Noise

`.tidal` files are opened in VS Code's `haskell` language mode only to activate the Tidal extension and get highlighting.  
Diagnostics from the Haskell Language Server on them are noise (`hie.yaml` tells it to ignore `patterns/`); do not rewrite a pattern to satisfy them.
