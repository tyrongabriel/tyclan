# Installing cnpg into the cluster
Following: https://cloudnative-pg.io/documentation/current/installation_upgrade/
## Latest manifest
```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.0.yaml
```

## Via helm
Charts: https://github.com/cloudnative-pg/charts
```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```
