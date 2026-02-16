# DevOps Platform Deployment Guide (Local First)

This guide provides a step-by-step walkthrough for deploying the platform on a local machine using Kind, and prepares for a future transition to a cloud environment.

## Prerequisites (Local)

Before you begin, ensure you have the following tools installed and configured:
- `git`
- `docker`
- `terraform` (v1.x)
- `kubectl` (v1.2x)
- `kind` (v0.11+)

---

## Stage 1: Version Control Setup

(This stage remains the same as the original guide, focused on setting up your Git repositories.)

---

## Stage 2: Infrastructure Provisioning (Local with Kind)

Next, create the local Kubernetes cluster using the `terraform-local` configuration.

1.  **Navigate to the Local Terraform Directory:**
    ```bash
    cd DevOps-Project-1/terraform-local
    ```

2.  **Deploy the Kind Cluster:**
    ```bash
    terraform init
    terraform apply --auto-approve
    ```
    - This command will use the Terraform Kind provider to create a local Kubernetes cluster named `devops-cluster`. The `kubeconfig` will be automatically set up.

3.  **Verify Cluster Connection:**
    ```bash
    kubectl cluster-info --context kind-devops-cluster
    ```

---

## Stage 3: Deploy Your First Application (Local)

With the local cluster running, deploy the `mini-finance-app`.

1.  **Build the Docker Image:**
    From the root of the `DevOps-Project-1` directory, build the application's Docker image.
    ```bash
    docker build -t mini-finance-app:local ./mini-finance-app
    ```

2.  **Load the Image into Your Kind Cluster:**
    The local cluster does not have access to your machine's Docker images by default. Load the image into the cluster:
    ```bash
    kind load docker-image mini-finance-app:local --name devops-cluster
    ```

3.  **Deploy the Application:**
    Apply the Kubernetes manifests to deploy the application to your cluster.
    ```bash
    kubectl apply -f ./mini-finance-app/k8s/
    ```

4.  **Verify the Deployment:**
    Check that the pod is running:
    ```bash
    kubectl get pods
    ```
    You should see a pod named `mini-finance-app-deployment-...` with a status of `Running`.

5.  **Access the Application:**
    To access the application from your local machine, forward a local port to the service:
    ```bash
    kubectl port-forward svc/mini-finance-app-service 8080:80
    ```
    You can now access the application at `http://localhost:8080` in your web browser.

---
## Stage 4: Transitioning to a Cloud Deployment (Future)

When you are ready to deploy to a cloud provider like GCP or AWS, you will need to make the following changes:

1.  **Infrastructure Provisioning:**
    - Use the configurations in `terraform/environments/staging` or `terraform/environments/production`.
    - You will need to configure `main.tf` with your cloud project details (e.g., GCP Project ID).
    - Run `terraform apply` in that directory to provision a GKE or EKS cluster.

2.  **Container Registry:**
    - You will need a container registry (like Google Artifact Registry, Amazon ECR, or Docker Hub) to store your application images.
    - Your CI/CD pipeline will be configured to push images to this registry.

3.  **CI/CD Pipeline (`.github/workflows/ci.yml`):**
    - The pipeline will need to be updated to:
        - Authenticate with your cloud provider.
        - Build and push the Docker image to your container registry with a unique tag (e.g., the Git commit SHA).
        - Update the image tag in your Kubernetes manifests (likely in the `config-repo` for GitOps).

4.  **Kubernetes Manifests:**
    - The `image` field in `deployment.yaml` will need to be changed from `mini-finance-app:local` to the path of the image in your container registry (e.g., `gcr.io/your-project/mini-finance-app:latest`).
    - The `imagePullPolicy` might be changed from `IfNotPresent` to `Always` to ensure the latest image is pulled.

5.  **Argo CD:**
    - Instead of applying manifests directly with `kubectl`, you will use Argo CD to manage deployments via GitOps, as described in the original guide.

---

(The original stages for Observability, Security, and CI/CD with Argo CD are still relevant and can be adapted for both local and cloud environments.)

