# Install with helm

```bash
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard -f kubernetes-dashboard.values.yaml
```

# Deploy ingress & Create RBAC
```bash
kubectl apply -f k8s-dashboard-ingress.yaml -f k8s-dashboard-rbac.yaml
```

# Get user access token
```bash
kubectl -n kubernetes-dashboard create token kubernetes-dashboard
```
