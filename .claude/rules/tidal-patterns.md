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

## In-File Comments

Comments in `.tidal` files use `--`. Use them to label sections (intro, build, drop) and to record what changed during live iteration.
When producing variants of a pattern, keep prior versions commented out for A/B comparison instead of deleting them.
