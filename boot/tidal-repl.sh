#!/bin/sh
# Tidal REPL launcher for the VS Code extension (tidalcycles.ghciPath).
# The extension spawns the REPL via /bin/sh without a working directory,
# so cd to the repo root (cabal needs the project context) and make sure
# the GHCup toolchain is on PATH even when VS Code is Dock-launched.
PATH="$HOME/.ghcup/bin:$HOME/.cabal/bin:$PATH"
export PATH
cd "$(dirname "$0")/.." && exec cabal repl "$@"
