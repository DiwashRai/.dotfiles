#!/usr/bin/env bash
set -euo pipefail

EXTERNALS_ROOT="${EXTERNALS_ROOT:-$HOME/externals}"
SOURCES="$EXTERNALS_ROOT/sources"
BUILDS="$EXTERNALS_ROOT/builds"
BIN="$EXTERNALS_ROOT/bin"
LOCAL="$EXTERNALS_ROOT/local"
LOGS="$EXTERNALS_ROOT/logs"

mkdir -p "$SOURCES" "$BUILDS" "$BIN" "$LOCAL" "$LOGS"

timestamp() { date +"%Y-%m-%d_%H-%M-%S"; }

# execute a command from the specified dir
in_dir() { ( cd "$1"; shift; "$@" ); }

# used to check for programs that can be run
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing tool: $1" >&2; exit 1; }; }

# used to check for packages that might be necessary for compilation
check_pkg() {
  local pkg="$1"
  if ! pkg-config --exists "$pkg"; then
    echo "Missing development package: $pkg" >&2
    exit 1
  fi
}

