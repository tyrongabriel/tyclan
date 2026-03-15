

```bash
# Add the repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create the namespace
kubectl create namespace monitoring

# Install the stack
# Note: We disable some components that k3s handles differently to avoid "Target Down" errors
# helm install prometheus prometheus-community/kube-prometheus-stack \
#   --namespace monitoring \
#   --set grafana.adminPassword=admin \
#   --set kubeControllerManager.enabled=false \
#   --set kubeScheduler.enabled=false \
#   --set kubeProxy.enabled=false
  
# Install kube-prometheus-stack with K3s values
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml \
  --set kubeControllerManager.enabled=false \
  --set kubeScheduler.enabled=false \
  --set kubeProxy.enabled=false
```
