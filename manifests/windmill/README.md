With Helm

```bash
# add the Windmill helm repo
helm repo add windmill https://windmill-labs.github.io/windmill-helm-charts/
# install chart with default values
helm install windmill-chart windmill/windmill  \
      --namespace=windmill             \
      --create-namespace
```
