# Software Template Example

This is a template for creating a new Python-based microservice.

## How to use this template

1.  **Create a new repository:** Create a new GitHub repository for your service.
2.  **Copy the files:** Copy all the files from this template into your new repository.
3.  **Customize your service:**
    - Update `app/main.py` with your application logic.
    - Change the `service_name` in the `kustomize/base/deployment.yaml` and `kustomize/base/service.yaml`.
    - Update the image name in `kustomize/base/kustomization.yaml`.
4.  **Push your code:** Push your new service to the `main` branch of your repository. The CI/CD pipeline will automatically build, test, and deploy your service to the staging environment.

## CI/CD

The CI/CD pipeline is defined in `.github/workflows/ci.yml`. It will:
- Run tests on every pull request.
- Build and push a Docker image to GCR on every merge to `main`.
- Scan the image for vulnerabilities.
- Update the manifests in the `config-repo` to trigger a deployment via Argo CD.
