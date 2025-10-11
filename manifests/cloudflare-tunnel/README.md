# Install cloudflared tunnel
Following: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deployment-guides/kubernetes/

```bash
## Create namespace and secrets
kubectl apply -f cloudflared-namespace.yaml
k-decrypt-apply cloudflared.secret.yaml

## Create egress rules (didnt help for quic, only blocket outgoing traffic to my websites)
#kubectl apply -f cloudflared-egress.yaml

## Install cloudflare tunnel
kubectl apply -f cloudflared.yaml
```
