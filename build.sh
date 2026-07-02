#!/usr/bin/env bash
set -e
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"
cmake -B "$BUILD_DIR" -DCMAKE_INSTALL_PREFIX="$HOME/.local" \
      -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD_DIR" -j"$(nproc)"
echo "✓ Сборка успешна. Запустите ./install.sh"