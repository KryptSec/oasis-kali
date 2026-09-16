#!/usr/bin/env bash
# Idempotent Cloud Agent setup for the oasis-kali image repo.
#
#   1. Install the Docker engine + fuse-overlayfs (nested-container storage).
#   2. Start dockerd.
#   3. Build the oasis-kali image from the repo Dockerfile so the toolkit is
#      ready to use as soon as an agent boots.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURSOR_DIR="$REPO_ROOT/.cursor"

export DEBIAN_FRONTEND=noninteractive

# 1. Docker engine + fuse-overlayfs. Only touch apt when docker is absent so
#    reruns stay fast and idempotent. --force-conf* keeps the fuse3 conffile
#    prompt non-interactive.
if ! command -v dockerd >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y \
    -o Dpkg::Options::=--force-confdef \
    -o Dpkg::Options::=--force-confold \
    docker.io fuse-overlayfs uidmap iptables ca-certificates curl git
fi

# 2. Bring the daemon up (idempotent).
bash "$CURSOR_DIR/docker-up.sh"

# 3. Build the image. Legacy builder + host networking because the nested
#    daemon runs without a NAT bridge.
sudo DOCKER_BUILDKIT=0 docker build --network host -t oasis-kali:local "$REPO_ROOT"

echo "oasis-kali image ready:"
sudo docker images oasis-kali:local
