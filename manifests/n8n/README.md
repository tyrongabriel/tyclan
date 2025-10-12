# Install N8n

Create namespace and add secrets (Just for initial httpauth)
```bash
kubectl apply -f namespace.yaml
k-decrypt-apply n8n.secret.yaml
```

Create configmap and database
```bash
kubectl apply -f config-map.yaml
kubectl apply -f db-cluster.yaml
```

Deploy n8n service, deployment and ingress
```bash
kubectl apply -f deployment.yaml -f service.yaml -f ingress.yaml
```
