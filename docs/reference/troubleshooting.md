# Troubleshooting

Common issues and solutions for Obsyk.

## Operator Issues

### Operator Pod Not Starting

**Symptoms**: Pod stuck in `Pending` or `CrashLoopBackOff`

**Check pod status**:
```bash
kubectl describe pod -n obsyk-system -l app=obsyk-operator
```

**Common causes**:

1. **Missing credentials secret**
   ```bash
   kubectl get secret -n obsyk-system obsyk-credentials
   ```
   Solution: Create the secret with correct credentials

2. **Resource limits too low**
   Check events for OOMKilled and increase memory limits

3. **Image pull errors**
   Verify network access to container registry

### Cluster Shows Disconnected

**Symptoms**: Cluster status is "Disconnected" in dashboard

**Check operator logs**:
```bash
kubectl logs -n obsyk-system -l app=obsyk-operator --tail=100
```

**Common causes**:

1. **Authentication failure**
   - Look for "401" or "authentication" errors in logs
   - Verify client ID and secret are correct
   - Regenerate credentials if needed

2. **Network connectivity**
   ```bash
   kubectl exec -n obsyk-system -it $(kubectl get pod -n obsyk-system -l app=obsyk-operator -o jsonpath='{.items[0].metadata.name}') -- curl -I https://api.obsyk.ai/health
   ```
   Solution: Check firewall rules, proxy settings

3. **TLS certificate issues**
   - Ensure cluster time is synchronized
   - Check for certificate expiry errors

### Missing Resources in Dashboard

**Symptoms**: Some namespaces or resources don't appear

**Common causes**:

1. **Namespace filtering**
   Check if namespace selector is configured:
   ```bash
   kubectl get cm -n obsyk-system obsyk-operator-config -o yaml
   ```

2. **RBAC permissions**
   Verify operator has required permissions:
   ```bash
   kubectl auth can-i list pods --as=system:serviceaccount:obsyk-system:obsyk-operator -A
   ```

3. **Sync delay**
   New resources may take a few seconds to appear. Wait and refresh.

## Dashboard Issues

### Cannot Log In

1. **Clear browser cookies** for `*.obsyk.ai`
2. **Try incognito mode** to rule out extensions
3. **Check browser console** for errors

### Slow Loading

1. **Large clusters** with many resources may take longer
2. **Check network** connection to `app.obsyk.ai`
3. **Try different browser** or disable extensions

## Getting Help

If issues persist:

1. Gather logs:
   ```bash
   kubectl logs -n obsyk-system -l app=obsyk-operator > operator-logs.txt
   ```

2. Note your cluster details:
   - Kubernetes version
   - Cloud provider
   - Operator version

3. Get support:
   - **Community Q&A**: [GitHub Discussions](https://github.com/obsyk/docs/discussions) - Best for general questions
   - **Bug reports**: [GitHub Issues](https://github.com/obsyk/obsyk-operator/issues) - For confirmed bugs in the operator
   - **Private inquiries**: [support@obsyk.ai](mailto:support@obsyk.ai) - For security issues or account questions
