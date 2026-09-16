#!/usr/bin/env bash
# Idempotently bring up the Docker daemon in the nested Cloud Agent VM.
#
# Cloud Agent VMs are themselves containers, so the daemon is configured for
# nested operation: the fuse-overlayfs storage driver (kernel overlayfs is not
# available) and no host iptables/bridge management. Container builds and runs
# therefore use `--network host` (see install.sh / the README notes).
set -euo pipefail

# Already responsive? Nothing to do.
if sudo docker info >/dev/null 2>&1; then
  echo "dockerd already running"
  exit 0
fi

# Clean up ephemeral runtime state left behind by a snapshot or a hard-killed
# daemon. These paths live on tmpfs on a real boot; removing them here makes a
# restart robust when dockerd is not responsive (persistent image/container
# data under /var/lib/docker is never touched).
sudo rm -f /var/run/docker.pid /run/docker.pid 2>/dev/null || true
sudo rm -rf /var/run/docker /run/docker /run/containerd 2>/dev/null || true

# Write the nested-container daemon config once.
sudo mkdir -p /etc/docker
if [ ! -f /etc/docker/daemon.json ]; then
  echo '{
  "storage-driver": "fuse-overlayfs",
  "iptables": false,
  "bridge": "none"
}' | sudo tee /etc/docker/daemon.json >/dev/null
fi

# Launch the daemon detached; logs go to /var/log/dockerd.log.
sudo mkdir -p /var/log
sudo bash -c 'nohup dockerd >>/var/log/dockerd.log 2>&1 &'

# Wait for readiness.
for _ in $(seq 1 30); do
  if sudo docker info >/dev/null 2>&1; then
    echo "dockerd is up"
    exit 0
  fi
  sleep 2
done

echo "dockerd failed to become ready" >&2
sudo tail -n 40 /var/log/dockerd.log >&2 || true
exit 1
