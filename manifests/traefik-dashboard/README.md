# Update Traefik
From: https://github.com/k3s-io/k3s/discussions/10679#discussioncomment-10277394

```bash
# Remove Old
helm uninstall traefik -n kube-system

# Add new
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik -n kube-system

# Or with version: helm upgrade traefik traefik/traefik -n kube-system --version 37.1.2
# Found with helm search repo traefik/traefik
```

## Update Traefik Dashboard

```bash
### save the values
helm show values traefik/traefik > value.yaml

### update and save
vim value.yaml

### apply
helm upgrade traefik traefik/traefik -f value.yaml -n kube-system
```
