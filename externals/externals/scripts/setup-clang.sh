#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "$0")/common.sh"

need cmake
need ninja
need curl
check_pkg zlib

# download links found here: https://gcc.gnu.org/mirrors.html
VER=21.1.0
MAJOR_VER=21
BASE_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$VER"
TAR_FILE="llvm-project-$VER.src.tar.xz"
SRC_DIR="$SOURCES/llvm-project-$VER"
SIG_FILE="$TAR_FILE.sig"

in_dir "$SOURCES" curl -fLO "$BASE_URL/$TAR_FILE"
in_dir "$SOURCES" curl -fLO "$BASE_URL/$SIG_FILE"

mkdir -p "$SRC_DIR"
in_dir "$SOURCES" tar -xJf "$TAR_FILE" -C "$SRC_DIR" --strip-components=1

OUT_DIR="$BUILDS/llvm-project-$VER"
PREFIX="$LOCAL/llvm-project-$VER"

mkdir -p "$OUT_DIR"

(
  cd "$OUT_DIR"
  cmake -S "$SRC_DIR/llvm" -B . -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lldb;lld" \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_ENABLE_ZLIB=ON

  cmake --build . -j"${JOBS:-$(nproc)}"
  cmake --install .
)

# symlinks (Clang already installs versioned names like clang-19)
ln -sfn "$PREFIX/bin/clang-$MAJOR_VER"   "$BIN/clang-$MAJOR_VER"
ln -sfn "$PREFIX/bin/lldb"                "$BIN/lldb-$MAJOR_VER"
ln -sfn "$PREFIX/bin/lld"                "$BIN/lld-$MAJOR_VER"

## Clean up intermediate objects, extracted source and downloaded files
rm -rf "$OUT_DIR"
rm -rf "$SRC_DIR"
rm -rf "$SOURCES/$TAR_FILE" "$SOURCES/$SIG_FILE"
