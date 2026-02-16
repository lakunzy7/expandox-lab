# Observability Stack Setup

This document provides instructions on how to set up the observability stack using Helm.

## 1. Prerequisites

- A running Kubernetes cluster.
- `kubectl` configured to connect to your cluster.
- `helm` v3 installed.

## 2. Create the Monitoring Namespace

```bash
kubectl create namespace monitoring
```

## 3. Install Kube-Prometheus-Stack

This chart will install Prometheus, Grafana, and Alertmanager.

```bash
# Add the prometheus-community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install the kube-prometheus-stack chart
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f prometheus-values.yaml
```

### Accessing Grafana

To access the Grafana dashboard, you can use `kubectl port-forward`:

```bash
kubectl port-forward svc/prometheus-grafana 8080:80 -n monitoring
```

The Grafana dashboard will be available at `http://localhost:8080`. The default username is `admin`. To get the password, run:

```bash
kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

## 4. Install Loki-Stack

This chart will install Loki for log aggregation and Promtail for log collection.

```bash
# Add the grafana Helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install the loki-stack chart
helm install loki grafana/loki-stack \
  --namespace monitoring \
  -f loki-values.yaml
```

## 5. Configure Grafana with Loki

The `loki-stack` chart automatically adds Loki as a data source in the Grafana instance deployed by `kube-prometheus-stack` if it's available. You should see the `loki` data source in Grafana's data source settings.

You can then use the "Explore" view in Grafana to query your logs using LogQL. For example, to see logs from the `my-app` application in the `production` namespace, you would use a query like:

```logql
{app="my-app", namespace="production"}
```
