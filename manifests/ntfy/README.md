

```bash
sops decrypt ./base/server.secret.yml --output ./base/decrypted.server.secret.yml && k apply -k ./base
```
