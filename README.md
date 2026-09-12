# Longhorn for Kubernetes — Tutorial Repository

Code and Kubernetes manifests for the Longhorn tutorial. Based on the article at:
https://thethoughtprocess.xyz/en/series/home-server/how-to-install-and-use-longhorn-kubernetes-storage

This repository contains all YAML manifests and shell scripts used in the tutorial. It is tuned for a Raspberry Pi K3s homelab cluster.

## Quick Start

### 1. Install host dependencies on each node

```bash
./installation/install-host-deps.sh
```

This installs `open-iscsi`, `nfs-common`, `xfsprogs`, and other required packages on every K3s node.

### 2. Install Longhorn

```bash
cd installation
./install-longhorn.sh
```

This adds the Longhorn Helm repository, applies `values.yaml`, and installs the chart into `longhorn-system`.

### 3. Verify installation

```bash
kubectl get storageclass
kubectl get pods -n longhorn-system
```

Access the Longhorn UI at `longhorn.home.arpa` (or the host you configured in `values.yaml`).

## Storage Classes

| Class | Replicas | Use case |
|---|---|---|
| `longhorn` (default) | 2 | General workloads with basic HA |
| `longhorn-zone-aware` | 3 | Critical workloads across 3 zones |
| `longhorn-node-aware` | 3 | Fewer nodes, controlled placement |
| `longhorn-no-ha` | 1 | Temporary data, caches, dev/test |

Apply a storage class:

```bash
kubectl apply -f storage-classes/02-zone-aware.yaml
```

## Snapshots and Backups

### Snapshots

Snapshots are like git commits for volumes. They allow rollback to a previous point in time.

```bash
kubectl apply -f snapshots-backups/01-snapshot-job.yaml
```

Link a PVC to the snapshot job by adding labels (see `04-pvc-labels.yaml`).

### Backups

Backups are stored externally in S3-compatible storage (GarageHQ, MinIO, AWS S3).

1. Update credentials in `snapshots-backups/03-backup-secret.yaml`.
2. Update `snapshots-backups/backup-values.yaml` with your backup target endpoint.
3. Apply:

```bash
helm upgrade longhorn longhorn/longhorn --namespace longhorn-system --values snapshots-backups/backup-values.yaml
kubectl rollout restart daemonset longhorn-manager -n longhorn-system
```

4. Apply the backup job:

```bash
kubectl apply -f snapshots-backups/02-backup-job.yaml
```

5. Label your PVCs to enable backups (see `04-pvc-labels.yaml`).

