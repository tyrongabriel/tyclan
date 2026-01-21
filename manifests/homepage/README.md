# Install using Manifests

```bash
kubectl apply \
    -f namespace.yaml \
    -f service-account.yaml \
    -f secret.yaml \
    -f rbac.yaml \
    -f deployment.yaml \
    -f service.yaml \
    -f ingress.yaml \
    -f config-map.yaml
```

## Create secrets for API tokens
```
sops decrypt homepage-tokens.secret.yaml | kubectl apply -f -
```

# Uninstall using Manifests

```bash
kubectl delete \
    -f namespace.yaml \
    -f service-account.yaml \
    -f secret.yaml \
    -f rbac.yaml \
    -f deployment.yaml \
    -f service.yaml \
    -f ingress.yaml \
    -f config-map.yaml
```
