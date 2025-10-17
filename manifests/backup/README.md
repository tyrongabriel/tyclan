For backups, snapshots are often used.

Things like cnpg needs the common VolumeSnapshot CRD to be installed:

```bash
helm repo add kubernetes-csi https://kubernetes-csi.github.io/docs
helm repo update

helm install csi-snapshotter kubernetes-csi/csi-snapshotter \
  --namespace kube-system \
  --set crd.install=true
```
