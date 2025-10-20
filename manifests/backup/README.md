For backups, snapshots are often used.

Things like cnpg needs the common VolumeSnapshot CRD to be installed:

```bash
# CRD's
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.3.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.3.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.3.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml

# Snapshot-Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.3.2/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v6.3.2/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml


```
