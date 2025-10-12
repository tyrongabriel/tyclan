# Authentik

## Install Helm chart

```bash
helm repo add authentik https://charts.goauthentik.io
helm repo update
# Apply with encrypted values
sops decrypt "values.secret.yaml" | helm upgrade --install authentik authentik/authentik -f - --namespace authentik
```

## Create your first output, provider and app

Step 1: Create an outpost, the gui offers an easy way to do this with the kubernetes integration. Disable the ingress by doing kubernetes_disable_components = ["ingress"] in the advanced settings

Step 2: Create a provider, lets say one for traefik, do a provider of type proxy, which will then point to traefik.<yourdomain> as the external host.

Step 3: Create an application, it should use the before created provider.

Step 4: Add the authentik middleware to traefik. The middleware itself should be created by the outpost thingy, but it can be manually created quite easily, it just needs to point to the outpost svc.

Step 5: Create a resource of traefiks IngressRoute type (You will most likely need to enable the cross namespace things for traefik) and add the middleware to the ignress of the dashboard
