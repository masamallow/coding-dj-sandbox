---
paths:
  - "**/*.tidal"
  - "patterns/**/*"
---

# TidalCycles Pattern Conventions

These rules apply only when editing `.tidal` files (live-coding patterns).

## Channel Conventions

- `d1` — drums (kick, snare, hats, percussion).
- `d2` — bass.
- `d3`–`d8` — harmonic and lead voices, FX, vocal samples.
- `d9`–`d16` — reserved for layering experiments.

These are conventions, not enforced rules.
When extending an existing file, follow whatever pattern is already in use there.

## Mini-notation First

Prefer the string-based mini-notation inside `sound "..."` and other `Pattern`-typed string parameters over explicit `cat` / `fastcat` / `stack` constructions.
Mini-notation is shorter, performance-friendly, and the form most Tidal documentation uses.

Use the explicit forms only when:

- The pattern requires conditional logic that mini-notation cannot express.
- The author explicitly asked for the long form for educational reasons.

## Iteration Style

A live-coded `.tidal` file is a working canvas, not a finished score.

- Keep prior variants commented out with `--` so the user can A/B compare during a session, instead of deleting them.
- Group related variants together.
  Annotate each block with a one-line comment describing the intent (e.g. `-- v2: half-time, more space`).
- Use `hush` at the top of the file as a "panic stop" reference, not as the default first line.

## Function Suggestions

When suggesting transformations, lean on the most common operators first:

- Time: `slow`, `fast`, `every`, `whenmod`, `sometimes`, `rev`.
- Density: `degrade`, `degradeBy`, `struct`.
- Pitch: `n`, `note`, `up`, `# octave`.
- Effects: `# room`, `# size`, `# delay`, `# delayfb`, `# delayt`, `# crush`.
- Routing / mixing: `# pan`, `# gain`, `# orbit`.

Reach for less-common combinators (`rolledBy`, `fix`, `wedge`, `swingBy`) only when the simpler forms cannot express the intent.

## Things to Avoid

- Do not use `do { ... }` blocks inside a `.tidal` file unless the user explicitly asks for them.
  `d1 $ ...` style is the live-coding norm.
- Do not introduce custom Haskell helper functions inside `.tidal` files;
  put them in `boot/BootTidal.hs` or a dedicated module under `boot/`.
- Do not generate patterns longer than ~16 cycles of unique material in a single statement; long sequences are fragile to edit live.
  Use functions like `every` or `seqP` to compose shorter pieces.
