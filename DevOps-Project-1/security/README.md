# Security Best Practices

This document summarizes the security best practices discussed in Phase 4.

## 1. Secret Management
- **DO NOT** store secrets in Git or Kubernetes manifests.
- **DO** use a dedicated secrets management tool like HashiCorp Vault or a cloud provider's secret manager.
- **DO** use the Secrets Store CSI Driver to mount secrets into pods.

## 2. Least-Privilege Access (RBAC)
- **DO** create specific `Roles` and `RoleBindings` for each application and user group.
- **DO NOT** use the `default` service account. Create a dedicated `ServiceAccount` for each application.
- **DO NOT** grant cluster-admin permissions unless absolutely necessary.

## 3. Pod Security
- **DO** enforce Pod Security Standards using the Pod Security Admission Controller.
- **DO** label your namespaces to enforce `baseline` or `restricted` policies. For example: `kubectl label ns my-app-namespace pod-security.kubernetes.io/enforce=restricted`
- **DO NOT** run containers as root. Use a non-root user in your Dockerfile.
- **DO NOT** allow privileged containers.

## 4. Network Security
- **DO** use `NetworkPolicies` to restrict traffic between pods.
- **DO** start with a default-deny policy for each namespace and explicitly allow required traffic.

## 5. Image Security
- **DO** scan your container images for vulnerabilities in your CI pipeline.
- **CONSIDER** using an admission controller like OPA/Gatekeeper or Kyverno to block the deployment of vulnerable images.
