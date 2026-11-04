#!/usr/bin/env bash
# Unduh font pixel (lisensi OFL) — font tidak ikut di repo karena biner.
# Tanpa font pun game tetap jalan (pakai font bawaan Godot).
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/fonts"
mkdir -p "$DIR"
curl -fsSL -o "$DIR/PressStart2P-Regular.ttf" https://github.com/google/fonts/raw/main/ofl/pressstart2p/PressStart2P-Regular.ttf
curl -fsSL -o "$DIR/VT323-Regular.ttf" https://github.com/google/fonts/raw/main/ofl/vt323/VT323-Regular.ttf
echo "Font terunduh ke $DIR"
