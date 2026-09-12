#!/bin/bash
# Install Longhorn on a K3s cluster (Raspberry Pi nodes)
# Prerequisites: Helm 3+, kubectl configured, at least 2 nodes with local storage
#
# Steps:
# 1. Install host dependencies on each node (run once per node):
#    sudo apt-get update && sudo apt-get install -y open-iscsi nfs-common util-linux bash curl jq xfsprogs
#    sudo systemctl enable --now iscsid
# 2. Add the Longhorn Helm repository.
# 3. Apply the values.yaml configuration.
# 4. Install the Helm chart.

set -euo pipefail

NAMESPACE="longhorn-system"
RELEASE_NAME="longhorn"
CHART_REF="longhorn/longhorn"
CHART_REPO="https://charts.longhorn.io"
VALUES_FILE="values.yaml"

echo "== Adding Longhorn Helm repository =="
helm repo add longhorn "$CHART_REPO"
helm repo update

echo "== Installing Longhorn into namespace $NAMESPACE =="
helm install "$RELEASE_NAME" "$CHART_REF" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --values "$VALUES_FILE"

echo "== Waiting for Longhorn pods to become ready =="
kubectl rollout status daemonset longhorn-manager -n "$NAMESPACE" --timeout=300s
kubectl rollout status deployment longhorn-ui -n "$NAMESPACE" --timeout=300s

echo "== Installation complete =="
echo "Verify storage classes:"
kubectl get storageclass
echo ""
echo "Access Longhorn UI at: longhorn.home.arpa (or configure ingress host)"
