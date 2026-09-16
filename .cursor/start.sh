#!/usr/bin/env bash
# Per-boot startup: ensure the Docker daemon is running. The oasis-kali image
# built during install persists in the environment snapshot, so this only needs
# to (re)start dockerd.
set -euo pipefail

CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$CURSOR_DIR/docker-up.sh"
