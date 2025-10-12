# Install Longhorn

## With Helm
From: https://longhorn.io/docs/1.10.0/deploy/install/install-with-helm/

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.10.0
```

# Configure dashboard ingress
(Currently no auth!)

```bash
kubectl apply -f longhorn-ingress.yaml
```
