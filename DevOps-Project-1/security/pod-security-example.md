# Applying Pod Security Admission

The Pod Security Admission Controller is a built-in feature of Kubernetes that enforces the [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

You can enforce these standards on a per-namespace basis by applying labels to the namespace.

## Enforcement Modes

There are three modes:
- `enforce`: Violating pods will be rejected.
- `audit`: Violating pods will be allowed, but an audit event will be logged.
- `warn`: Violating pods will be allowed, but a warning will be sent to the user.

You can also specify a version for the policy, but `latest` is usually sufficient.

## Example

To enforce the `restricted` policy on a namespace called `my-app-ns`, you would run the following command:

```bash
kubectl label --overwrite ns my-app-ns \
  pod-security.kubernetes.io/enforce=restricted
```

This is the most secure policy and should be your goal for all production workloads.

To enforce the `baseline` policy, which is less restrictive but still prevents known privilege escalations:

```bash
kubectl label --overwrite ns my-app-ns \
  pod-security.kubernetes.io/enforce=baseline
```

You can also use different modes for different policies. For example, you could enforce `baseline` but `audit` for `restricted`, to see what changes would be needed to become fully compliant:

```bash
kubectl label --overwrite ns my-app-ns \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/audit=restricted
```
