#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/nvim"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

echo "Removing everything in '$CONFIG_DIR' except 'lazy-lock.json'…"
find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 \
     ! -name "lazy-lock.json" \
     -exec rm -rf {} +

cd "$SCRIPT_DIR"
echo "Running: stow nvim"
stow nvim

echo "✅ Done."
