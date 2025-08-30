#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "$0")/common.sh"

# download links found here: https://gcc.gnu.org/mirrors.html
VER=15.2.0
MAJOR_VER=15
BASE_URL="https://mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$VER"
TAR_FILE="gcc-$VER.tar.xz"
SIG_FILE="$TAR_FILE.sig"

in_dir "$SOURCES" curl -fLO "$BASE_URL/$TAR_FILE"
in_dir "$SOURCES" curl -fLO "$BASE_URL/$SIG_FILE"
in_dir "$SOURCES" curl -fLO "$BASE_URL/sha512.sum"

# verify sha512
in_dir "$SOURCES" bash -c "grep ' $TAR_FILE\$' sha512.sum | sha512sum -c -"

in_dir "$SOURCES" tar -xJf "$TAR_FILE"

SRC_DIR="$SOURCES/gcc-$VER"
OUT_DIR="$BUILDS/gcc-$VER"
PREFIX="$LOCAL/gcc-$VER"

in_dir "$SRC_DIR" ./contrib/download_prerequisites
mkdir -p "$OUT_DIR"

(
  cd "$OUT_DIR"
  "$SRC_DIR/configure" \
    --prefix="$PREFIX" \
    --enable-languages=c,c++ \
    --disable-multilib \
    --program-suffix="$MAJOR_VER"

  make -j"${JOBS:-$(nproc)}"
  make install
)

ln -sfn "$PREFIX/bin/gcc$MAJOR_VER" "$BIN/gcc$MAJOR_VER"
ln -sfn "$PREFIX/bin/g++$MAJOR_VER" "$BIN/g++$MAJOR_VER"

# Clean up intermediate objects, extracted source and downloaded files
rm -rf "$OUT_DIR"
rm -rf "$SRC_DIR"
rm -rf "$SOURCES/$TAR_FILE" "$SOURCES/$SIG_FILE" "$SOURCES/sha512.sum"
