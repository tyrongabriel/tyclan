# Create tailscale ingress
Source: https://joshrnoll.com/securely-exposing-applications-on-kubernetes-with-tailscale/
Create tailscale namespace with escalation
```bash
kubectl create namespace tailscale && kubectl label namespace tailscale pod-security.kubernetes.io/enforce=privileged
```

Add to the tailscale ACL the following:
```json
"tagOwners": {
   "tag:k8s-operator": [],
   "tag:k8s": ["tag:k8s-operator"],
}
```

Add Oauth client in tailscale console
Read/Write on Devices/Core
Read/Write on Keys/Auth Keys
(Both with tag k8s-operator)

## Install tailscale operator
```bash
# Either decrypt sops file directly or use
k-decrypt-apply tailscale-operator.secret.yaml
```
## Deploy example
```bash
kubectl apply -f nginx-hello-world.yaml
```






# DEPRECATED

Install tailscale operator
```bash
## With hardcoded creds
helm repo add tailscale https://pkgs.tailscale.com/helmcharts && helm repo update

helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId="<OAauth client ID>" \
  --set-string oauth.clientSecret="<OAuth client secret>" \
  --wait


## With secret deployed
k-decrypt-apply tailscale-operator-oauth-secret.yaml # Creates secret tailscale-oauth-creds
helm repo add tailscale https://pkgs.tailscale.com/helmcharts && helm repo update


helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set oauthSecretVolume.secret.secretName=tailscale-oauth-creds \
  --set 'oauthSecretVolume.secret.items[0].key=client_id' \
  --set 'oauthSecretVolume.secret.items[0].path=client_id' \
  --set 'oauthSecretVolume.secret.items[1].key=client_secret' \
  --set 'oauthSecretVolume.secret.items[1].path=client_secret' \
  --wait
```

# Deploy example
```bash
kubectl apply -f nginx-hello-world.yaml
```
