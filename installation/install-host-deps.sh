#!/bin/bash
# Install host dependencies on each K3s node for Longhorn
# Run this on EVERY node in your cluster.
#
# Dependencies:
#   open-iscsi   - iSCSI initiator for Longhorn volume attachment
#   nfs-common   - NFS client for backup targets
#   util-linux   - util-linux utilities (blkid, lsblk, etc.)
#   bash         - Shell
#   curl         - HTTP client
#   jq           - JSON processor
#   xfsprogs     - XFS filesystem tools
#
# Usage: Run as root or with sudo on each node.

set -euo pipefail

echo "== Installing Longhorn host dependencies =="
apt-get update
apt-get install -y open-iscsi nfs-common util-linux bash curl jq xfsprogs

echo "== Enabling iSCSI daemon =="
systemctl enable --now iscsid

echo "== Host dependencies installed =="
echo "Verify iSCSI is running:"
systemctl status iscsid --no-pager
