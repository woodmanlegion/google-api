#!/usr/bin/env bash
set -e
DEST="${1:-/usr/local/bin/google-api}"
mkdir -p "$(dirname "$DEST")"
install -Dm755 bin/google-api "$DEST"
echo "Installed to $DEST"
