# Configure kubernetes dashboard

## Install kubernetes dashboard with helm
```bash
# 1. Add the official Kubernetes Dashboard Helm repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

# 2. Update your local Helm chart repository cache
helm repo update

# 3. Install the Dashboard, setting it to use HTTP and a ClusterIP service
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --create-namespace --namespace kubernetes-dashboard \
  --set protocolHttp=true \
  --set service.type=ClusterIP
```

## Apply the dashboard manifest
```bash
k3s kubectl apply -f dashboard-config.yaml
```

## Retreive login token
```bash
# This command creates and prints a long-lived Bearer Token
k3s kubectl -n kubernetes-dashboard create token admin-user
```
