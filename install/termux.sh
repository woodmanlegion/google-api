#!/usr/bin/env bash
set -e
DEST="${1:-/data/data/com.termux/files/usr/bin/google-api}"
mkdir -p "$(dirname "$DEST")"
install -Dm755 bin/google-api "$DEST"
echo "Installed to $DEST"
