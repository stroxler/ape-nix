#!/usr/bin/env bash

# Install homebrew casks for macOS.
# Run this manually after bootstrapping homebrew.

set -euo pipefail

CASKS=(
  emacs
  rectangle
  clipy
)

for cask in "${CASKS[@]}"; do
  echo "Installing $cask..."
  brew install --cask "$cask"
done
