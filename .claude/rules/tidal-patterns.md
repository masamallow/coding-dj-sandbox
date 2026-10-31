---
paths:
  - "**/*.tidal"
---

# Tidal Pattern Conventions

Rules that matter only when writing `.tidal` files;
[AGENTS.md](../../AGENTS.md) links here for agents that do not load path-scoped rules automatically.  
Repository-wide rules stay in AGENTS.md: one idea per file, commented-out variants, Strudel translation, HLS noise, and the editor keybindings.

## Pattern Layout

By convention, `d1` carries drums (kick, snare, hats), `d2` carries bass, and `d3` and above carry harmonic and lead voices, FX, and vocal samples.  
Follow whatever layout is already in use when extending an existing file.

## Mini-notation First

Prefer string mini-notation inside `sound "..."` and other `Pattern`-typed string parameters over verbose `cat` / `fastcat` / `stack` constructions,
unless a feature requires the explicit form.

## One Statement per Block

Editors evaluate either the current line or the contiguous block of non-blank lines around the cursor.  
Separate statements with blank lines so each block is exactly one statement, and never expect a file to run top-to-bottom.

## In-File Comments

Comments use `--`.  
Use them to label sections (intro, build, drop) and to record what changed during live iteration.
