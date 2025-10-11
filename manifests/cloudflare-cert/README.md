# Setup Instructions:
1. **Create Cloudflare API Token**:
   - Go to Cloudflare Dashboard > Profile > API Tokens
   - Create a token with these permissions:
     - Zone: DNS: Edit
     - Zone: Zone: Read
   - Copy the token and replace `<YOUR_CLOUDFLARE_API_TOKEN>` in the manifest

2. **Replace Placeholders**:
   - `<YOUR_EMAIL_ADDRESS>`: Your email for Let's Encrypt
   - `<YOUR_CLOUDFLARE_API_TOKEN>`: Your Cloudflare API token

3. **Apply Manifests**:
   ```bash
   # Install cert-manager
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml
   ```
   ```bash
   # Create secret and create cloudflare cert manager
   k-decrypt-apply cloudflare-cert-manager.secret.yaml
   ```

## Check certs
```bash
kubectl get certificate -n YOUR_NAMESPACE
kubectl describe certificate YOUR_TLS_SECRET_NAME -n YOUR_NAMESPACE
```

# New ingress with tls:
```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: YOUR_INGRESS_NAME
  namespace: YOUR_NAMESPACE
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    cert-manager.io/cluster-issuer: cloudflare-issuer
spec:
  tls:
  - hosts:
    - YOUR_SUBDOMAIN.tyrongabriel.com
    secretName: YOUR_TLS_SECRET_NAME
  rules:
  - host: YOUR_SUBDOMAIN.tyrongabriel.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: YOUR_SERVICE_NAME
            port:
              number: 80
```
