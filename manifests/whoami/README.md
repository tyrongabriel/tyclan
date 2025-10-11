# Demo WhoAmI

This is a simple deployment of the [WhoAmI](https://github.com/containous/whoami) container.

## Usage

```bash
kubectl apply -f whoami.yaml
```

## Cleanup

```bash
kubectl delete -f whoami.yaml
```

# Ingress
After setting up either (or both) cloudflared and tailscale for ingress, create the respective ingress resources.

## Cloudflare

```bash
kubectl apply -f whoami-cf-ingress.yaml
```

## Tailscale

```bash
kubectl apply -f whoami-ts-ingress.yaml
```
