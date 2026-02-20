# Mini Finance App: Complete Beginner-Friendly Deployment Guide

Welcome! This guide is designed for DevOps engineers who are new to **CI/CD pipelines**, **Docker**, **Kubernetes**, and **GitOps**. We'll walk through every step with detailed explanations.

---

## Table of Contents
1. [Understanding the Big Picture](#understanding-the-big-picture)
2. [Prerequisites & What You Need](#prerequisites--what-you-need)
3. [Part 1: What is CI/CD?](#part-1-what-is-cicd)
4. [Part 2: Understanding Our Architecture](#part-2-understanding-our-architecture)
5. [Part 3: One-Time Cluster Setup](#part-3-one-time-cluster-setup)
6. [Part 4: Setting Up GitHub Actions (CI Pipeline)](#part-4-setting-up-github-actions-ci-pipeline)
7. [Part 5: Deploying with Argo CD (CD Pipeline)](#part-5-deploying-with-argo-cd-cd-pipeline)
8. [Part 6: Making Your First Deployment](#part-6-making-your-first-deployment)
9. [Part 7: Monitoring & Troubleshooting](#part-7-monitoring--troubleshooting)
10. [Frequently Asked Questions](#frequently-asked-questions)

---

## Understanding the Big Picture

### What Are We Building?

We have a simple web application called **mini-finance-app** (a static website served by Nginx). Our goal is to:
1. **Automate building** the application into a Docker container (CI - Continuous Integration)
2. **Automate deployment** to Kubernetes (CD - Continuous Deployment)
3. **Keep everything in Git** as the source of truth (GitOps)

### The Flow (Simple Version)

```
Developer pushes code to GitHub
         ↓
GitHub Actions automatically builds a Docker image
         ↓
GitHub Actions pushes the image to Docker Hub
         ↓
GitHub Actions updates the Kubernetes manifest file
         ↓
Argo CD detects the change in Git
         ↓
Argo CD automatically deploys the new version to Kubernetes
         ↓
Users see the new version running!
```

---

## Prerequisites & What You Need

Before starting, ensure you have:

### **Tools to Install**

1. **kubectl** - Command-line tool to interact with Kubernetes
   - Used to: Check cluster status, manage resources, apply manifests
   - Installation: Follow [kubectl installation guide](https://kubernetes.io/docs/tasks/tools/)

2. **Docker** - Container platform (not strictly needed for this guide, but good to understand)
   - Used to: Build container images locally
   - Installation: Download from [docker.com](https://www.docker.com/)

3. **Git** - Version control system
   - Used to: Push code and manage repository
   - Installation: Follow [git installation guide](https://git-scm.com/)

### **Accounts to Create**

1. **GitHub Account** - Where your code lives
   - Create at [github.com](https://github.com)
   - Fork the `expandox-lab` repository

2. **Docker Hub Account** - Where Docker images are stored
   - Create at [hub.docker.com](https://hub.docker.com)
   - You'll use your credentials for pulling private images

3. **Kubernetes Cluster** - Where your app runs
   - Can be: `kind` (local), minikube, AWS EKS, Google GKE, Azure AKS, etc.
   - This guide assumes you have a running cluster

### **Knowledge You Should Have**

- Basic command-line/terminal usage
- Git basics (clone, push, commit)
- What Docker containers are (general concept)
- What Kubernetes is (general concept)

---

## Part 1: What is CI/CD?

### CI - Continuous Integration

**What is it?** Automatically test and build your code every time you push changes.

**Why do we need it?**
- **Manual testing is slow** - Testing by hand takes time and is error-prone
- **Consistency** - The same build process runs every time
- **Catch errors early** - Find problems before they reach production

**In our case:**
- Every time you push code to GitHub, GitHub Actions automatically:
  - Builds a Docker image
  - Tags it with the commit SHA (a unique identifier)
  - Pushes it to Docker Hub

### CD - Continuous Deployment

**What is it?** Automatically deploy your tested code to the production environment.

**Why do we need it?**
- **No manual deployments** - Reduces human error
- **Faster releases** - Deploy new versions instantly
- **GitOps principle** - Git is your single source of truth

**In our case:**
- When the manifest file changes (because GitHub Actions updated it), Argo CD:
  - Detects the change
  - Automatically deploys the new version to your cluster
  - No manual `kubectl apply` commands needed

### The Complete Flow Explained

```
Step 1: Developer writes code
  └─ Edits application files (HTML, CSS, JS, etc.)
  └─ Tests locally
  └─ Commits and pushes to GitHub

Step 2: GitHub Actions (CI) - Automatic Build
  └─ GitHub detects the push
  └─ Runs the workflow defined in .github/workflows/ci.yml
  └─ Builds Docker image
  └─ Pushes image to Docker Hub
  └─ Updates Kubernetes manifest with new image tag

Step 3: Git Repository Updated
  └─ The manifest file is now different
  └─ Git contains the "desired state"

Step 4: Argo CD (CD) - Automatic Deployment
  └─ Argo CD watches the Git repository continuously
  └─ Detects the manifest change
  └─ Compares it with current cluster state
  └─ Applies the changes to the Kubernetes cluster

Step 5: Users See New Version
  └─ New pods start with new image
  └─ Old pods are terminated
  └─ Users access the new version
```

---

## Part 2: Understanding Our Architecture

### The Components We Use

#### 1. **GitHub** - The Code Repository
- Stores your application code
- Stores your Kubernetes manifests
- Triggers automation via GitHub Actions

#### 2. **GitHub Actions** - The CI Engine
- Runs when code is pushed
- Builds Docker images
- Pushes images to Docker Hub
- Updates Kubernetes manifests

#### 3. **Docker Hub** - The Container Registry
- Stores Docker images
- Your cluster pulls images from here
- Like a "storage locker" for container images

#### 4. **Kubernetes Cluster** - The Runtime
- Where your application actually runs
- Has multiple namespaces (dev, production)
- Runs Argo CD

#### 5. **Argo CD** - The CD Engine
- Runs inside your Kubernetes cluster
- Continuously watches your Git repository
- Automatically applies manifest changes to the cluster

### How They Work Together

```
┌──────────────┐
│   GitHub     │  ← Developer pushes code here
│  Repository  │
└──────┬───────┘
       │
       │ GitHub Actions detects push
       ↓
┌──────────────────────┐
│  GitHub Actions      │
│  (Build & Push)      │  ← Builds Docker image
│                      │  ← Pushes to Docker Hub
│                      │  ← Updates manifest in Git
└──────┬───────────────┘
       │
       │ Updates Git
       ↓
┌──────────────┐
│   GitHub     │
│  Repository  │  ← Now contains updated manifest
│  (Manifest)  │
└──────┬───────┘
       │
       │ Argo CD watches for changes
       ↓
┌──────────────────────────────────────┐
│  Kubernetes Cluster                  │
│  ┌────────────────────────────────┐  │
│  │  Argo CD (watching Git)        │  │  ← Detects change
│  │  ┌──────────────────────────┐  │  │
│  │  │ mini-finance-app (dev)   │  │  │  ← New image deployed
│  │  │ mini-finance-app (prod)  │  │  │  ← New image deployed
│  │  └──────────────────────────┘  │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

### File Structure

```
expandox-lab/
├── .github/
│   └── workflows/
│       └── ci.yml                    ← GitHub Actions automation
├── DevOps-Project-1/
│   ├── mini-finance-app/
│   │   ├── Dockerfile               ← Defines how to build Docker image
│   │   ├── index.html               ← Your application code
│   │   └── ...
│   ├── k8s/
│   │   ├── dev/
│   │   │   └── manifests.yaml       ← Kubernetes manifest for dev
│   │   └── production/
│   │       └── manifests.yaml       ← Kubernetes manifest for production
│   └── gitops/
│       ├── v2-add-cluster-and-repo/ ← Argo CD repository config
│       ├── v5-app-project/          ← Argo CD app project
│       └── v6-application-sets/     ← Argo CD application sets
```

---

## Part 3: One-Time Cluster Setup

These steps prepare your Kubernetes cluster for deployment. You only do this **once**.

### Step 3.1: Install Argo CD

**What is this doing?**
- Installing Argo CD (the continuous deployment tool) into your cluster
- Creating a dedicated namespace called `argocd` to keep Argo CD organized

**Why?**
- Argo CD needs to run somewhere - that somewhere is your cluster
- Namespaces keep things organized (like folders on a computer)

**Run these commands:**

```bash
# Create a namespace for Argo CD (a logical grouping)
kubectl create namespace argocd

# Install Argo CD into that namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**What happened?**
- Kubernetes downloaded the Argo CD installation manifest
- Applied it to your cluster
- Created all necessary Argo CD components (pods, services, etc.)

**Verify it worked:**
```bash
# Check if Argo CD pods are running
kubectl get pods -n argocd

# You should see pods like: argocd-server, argocd-controller-manager, etc.
```

### Step 3.2: Register Your Git Repository with Argo CD

**What is this doing?**
- Telling Argo CD: "Watch this GitHub repository for changes"
- Giving Argo CD permission to read your manifests

**Why?**
- Argo CD needs to know which Git repository to watch
- It reads the manifests from there to know what to deploy

**File: `DevOps-Project-1/gitops/v2-add-cluster-and-repo/add-public-repo.yaml`**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: expandox-lab-repo          # Name of this repository config
  namespace: argocd                # Must be in argocd namespace
  labels:
    argocd.argoproj.io/secret-type: repository  # Tells Argo CD this is a repo secret
stringData:
  type: git                        # This is a Git repository
  url: https://github.com/lakunzy7/expandox-lab.git  # Your repo URL
```

**What each field means:**
- `metadata.name` - A friendly name for this repository configuration
- `namespace: argocd` - Argo CD only looks in the argocd namespace
- `stringData.type: git` - Tells Argo CD it's a Git repository
- `stringData.url` - The URL to your repository

**Apply this:**
```bash
kubectl apply -f DevOps-Project-1/gitops/v2-add-cluster-and-repo/add-public-repo.yaml
```

**Verify:**
```bash
# List all repository secrets in argocd namespace
kubectl get secrets -n argocd
# You should see: expandox-lab-repo
```

---

## Part 4: Setting Up GitHub Actions (CI Pipeline)

### Understanding GitHub Actions

**What is GitHub Actions?**
- A automation platform built into GitHub
- Runs tasks (called workflows) when events happen (like pushing code)
- Runs on GitHub's servers (you don't need your own CI server)

**File: `.github/workflows/ci.yml`**

This file tells GitHub Actions what to do when you push code. Let's break it down:

### The Workflow File Explained

```yaml
name: CI - Build, Push, and Update Manifests

# TRIGGER: When does this workflow run?
on:
    push:
        branches:
            - "**"              # Run on push to ANY branch
```

**What this means:**
- Whenever you push code to any branch, GitHub runs this workflow

---

### Step 4.1: Set Up Docker Hub Credentials

**Why do we need this?**
- Your Docker images are private (not public)
- You need credentials to push to Docker Hub
- GitHub Actions needs these credentials

**Where do we put the credentials?**
- GitHub Secrets (a secure place to store sensitive data)
- GitHub Actions can access them, but they're not visible in your code

**Step-by-step:**

1. **Go to Docker Hub and create a Personal Access Token:**
   - Log in to [hub.docker.com](https://hub.docker.com)
   - Click your profile → Account Settings → Security
   - Click "New Access Token"
   - Give it a name like "GitHub Actions"
   - Keep the default permissions
   - Copy the token (it looks like: `dckr_pat_xxxxxxxxxxxxxxxx`)

2. **Add secrets to GitHub:**
   - Go to your repository on GitHub
   - Click Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Add first secret:
     - Name: `DOCKER_USERNAME`
     - Secret: Your Docker Hub username (e.g., `lakunzy`)
   - Add second secret:
     - Name: `DOCKERHUB_TOKEN`
     - Secret: The token you just created

**Why these names?**
- These names match what the workflow file looks for
- If names don't match, workflow won't find the secrets

---

### Step 4.2: Understanding the Workflow Steps

**File: `.github/workflows/ci.yml` (continued)**

#### Step 1: Checkout Code
```yaml
- name: Checkout code
  uses: actions/checkout@v3
  with:
      fetch-depth: 0
```

**What this does:**
- Downloads your code from GitHub to the GitHub Actions server
- This is necessary so GitHub Actions can see your Dockerfile and code

**Why `fetch-depth: 0`?**
- Fetches the complete history
- Needed so the workflow knows the full git context

---

#### Step 2: Set Up Docker Buildx
```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v2
```

**What this does:**
- Prepares Docker's build tool on the GitHub Actions server
- Buildx is Docker's advanced build system (faster, supports multiple platforms)

**Why do we need this?**
- To build Docker images on GitHub's servers

---

#### Step 3: Login to Docker Hub
```yaml
- name: Login to Docker Hub
  if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
  uses: docker/login-action@v2
  with:
      username: ${{ secrets.DOCKER_USERNAME }}
      password: ${{ secrets.DOCKERHUB_TOKEN }}
```

**What this does:**
- Authenticates with Docker Hub using your credentials
- Now the server can push images to your Docker Hub account

**The `if` statement:**
- Only logs in if you're pushing to `main` or `develop`
- Saves time on other branches (they don't need to push)

**What is `${{ secrets.DOCKER_USERNAME }}`?**
- This is placeholder syntax that GitHub replaces with the actual secret value
- GitHub never shows the actual value in logs (it's replaced with `***`)

---

#### Step 4: Build and Push Docker Image
```yaml
- name: Build and Push Image
  id: docker_build
  uses: docker/build-push-action@v4
  with:
      context: ./DevOps-Project-1/mini-finance-app
      push: ${{ github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop' }}
      tags: |
          lakunzy/mini-finance-app:${{ github.sha }}
          lakunzy/mini-finance-app:latest
```

**What this does:**
- Builds a Docker image from `DevOps-Project-1/mini-finance-app/Dockerfile`
- Pushes it to Docker Hub with two tags:
  - `lakunzy/mini-finance-app:abc123def456` (where abc123def456 is the commit SHA)
  - `lakunzy/mini-finance-app:latest` (always points to latest version)

**Why two tags?**
- **Latest tag:** Easy to find the most recent version
- **SHA tag:** Know exactly which commit this image came from (full traceability)

**What is `github.sha`?**
- A unique identifier for your commit
- Example: `abc123def456789` (first 12 characters shown in Docker images)

---

#### Step 5: Update Development Manifest
```yaml
- name: Update Development Manifest
  if: github.ref == 'refs/heads/develop'
  env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
      git config --global user.name 'github-actions[bot]'
      git config --global user.email 'github-actions[bot]@users.noreply.github.com'
      sed -i "s|image:.*|image: lakunzy/mini-finance-app:${{ github.sha }}|g" DevOps-Project-1/k8s/dev/manifests.yaml
      git add DevOps-Project-1/k8s/dev/manifests.yaml
      git commit -m "ci: update dev image tag to ${{ github.sha }}"
      git push https://${{ github.actor }}:${GITHUB_TOKEN}@github.com/${{ github.repository }}.git HEAD:develop
```

**What this does:**
- Configures Git with a bot name (so commits show as from "github-actions[bot]")
- Updates the image tag in the dev manifest file
- Commits the change with a message
- Pushes the change back to GitHub

**Why?**
- The Kubernetes manifest needs to know which image to use
- We update it with the new image tag so Argo CD deploys the new version

**Breaking down the sed command:**
```bash
sed -i "s|image:.*|image: lakunzy/mini-finance-app:${{ github.sha }}|g" DevOps-Project-1/k8s/dev/manifests.yaml
```
- `s|old|new|g` = Replace pattern
- `image:.*` = Find anything starting with "image:"
- `image: lakunzy/mini-finance-app:${{ github.sha }}` = Replace with new image tag
- Results in: `image: lakunzy/mini-finance-app:abc123def456`

---

#### Step 6: Update Production Manifest
```yaml
- name: Update Production Manifest
  if: github.ref == 'refs/heads/main'
  env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
      # Same as development, but updates production manifest
      # Only runs when pushing to 'main' branch
```

**This is identical to the development step, but:**
- Only runs when pushing to `main` branch
- Updates `production/manifests.yaml` instead of `dev/manifests.yaml`

---

### Step 4.3: Deploy the Workflow

```bash
# The workflow file is already in place at:
# .github/workflows/ci.yml

# You've already configured the secrets, so you're ready!
# The workflow will automatically run on your next push
```

**To test it:**
```bash
# Make a small change and push
echo "# test" >> README.md
git add README.md
git commit -m "test: trigger workflow"
git push origin develop

# Go to GitHub → Actions tab to see it run
```

---

## Part 5: Deploying with Argo CD (CD Pipeline)

### Understanding Argo CD

**What is Argo CD?**
- A Kubernetes controller that watches your Git repository
- Whenever Git changes, it automatically updates your cluster
- This is "GitOps" - Git is your source of truth

**Why Argo CD instead of manual deployments?**
- **Automatic:** No manual `kubectl apply` commands
- **Consistent:** Same deployment process every time
- **Auditable:** Every change is in Git with commit history
- **Declarative:** You declare what you want, Argo CD figures out how to achieve it

### The Kubernetes Manifests

**File: `DevOps-Project-1/k8s/dev/manifests.yaml`**

Let's understand each section:

#### 1. Namespace Definition
```yaml
apiVersion: v1
kind: Namespace
metadata:
    name: mini-finance-dev
```

**What is this?**
- Creates a Kubernetes namespace (a virtual cluster within your cluster)
- Think of it like a folder that keeps things organized

**Why do we need namespaces?**
- Separate dev, staging, and production environments
- Prevent accidental deletion of production resources
- Different access controls per namespace

**What it does:**
- Creates an isolated environment where only dev resources live

---

#### 2. Image Pull Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
    name: dockerhub-creds
    namespace: mini-finance-dev
type: kubernetes.io/dockerconfigjson
stringData:
    .dockerconfigjson: |
      {
        "auths": {
          "https://index.docker.io/v1/": {
            "username": "lakunzy",
            "password": "dckr_pat_xxxxx",
            "auth": "base64encodedcredentials"
          }
        }
      }
```

**What is this?**
- Stores Docker Hub credentials in Kubernetes
- Used by Kubernetes to pull private images from Docker Hub

**Why do we need it?**
- Your mini-finance-app image is private
- Kubernetes needs credentials to pull it
- Without this secret, you get `ImagePullBackOff` errors

**How does it work?**
- Kubernetes sees in the Deployment: `imagePullSecrets: [dockerhub-creds]`
- When it needs to pull the image, it uses these credentials

---

#### 3. Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: mini-finance-app
    namespace: mini-finance-dev
spec:
    replicas: 1                    # How many copies of the app to run
    selector:
        matchLabels:
            app: mini-finance-app  # Label selector to find pods
    template:
        metadata:
            labels:
                app: mini-finance-app
        spec:
            imagePullSecrets:
                - name: dockerhub-creds  # Use credentials to pull image
            containers:
                - name: mini-finance-app
                  image: lakunzy/mini-finance-app:latest  # Image to run
                  imagePullPolicy: IfNotPresent
                  ports:
                      - containerPort: 80
                  resources:
                      requests:
                          memory: "64Mi"
                          cpu: "100m"
                      limits:
                          memory: "128Mi"
                          cpu: "200m"
```

**What is a Deployment?**
- A Kubernetes object that manages running your application
- Ensures the right number of replicas are always running
- Handles rolling updates (replacing old pods with new ones)

**Breaking it down:**

**replicas: 1**
- Kubernetes will maintain 1 copy of your app at all times
- If the pod crashes, Kubernetes automatically starts a new one

**matchLabels**
- Kubernetes uses labels to find and manage pods
- Think of it like a name tag: "This pod is my mini-finance-app"

**containers**
- What container image to run
- Port 80 (HTTP) - where the app listens
- Resource requests/limits - how much memory/CPU it can use

**imagePullSecrets**
- Before running the image, use the `dockerhub-creds` secret to authenticate
- This is how Kubernetes pulls your private image

**image: lakunzy/mini-finance-app:latest**
- This is what GitHub Actions updates!
- When GitHub Actions pushes a new image, this line changes to the new SHA
- When Argo CD sees this change, it redeploys the pod

---

#### 4. Service
```yaml
apiVersion: v1
kind: Service
metadata:
    name: mini-finance-app-service
    namespace: mini-finance-dev
spec:
    selector:
        app: mini-finance-app   # Direct traffic to pods with this label
    type: ClusterIP
    ports:
        - protocol: TCP
          port: 80              # Port accessible inside cluster
          targetPort: 80        # Port on container
```

**What is a Service?**
- A stable way to access your app from within the cluster
- Pod IPs change when pods are recreated, but Service IP stays the same

**Why do we need it?**
- Pods are temporary (they can be replaced anytime)
- Services provide a stable hostname/IP to reach them
- Other apps can reach your service via `mini-finance-app-service.mini-finance-dev`

---

### Step 5.1: Create Image Pull Secret in Cluster

**Important:** This must be done BEFORE deploying the app, and you need the same credentials.

**Create the secret for dev environment:**
```bash
kubectl create secret docker-registry dockerhub-creds \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=lakunzy \
  --docker-password=dckr_pat_xxxxxxxxxxxxxxxx \
  --namespace=mini-finance-dev
```

**Breaking this down:**
- `docker-registry` - Type of secret (for pulling images)
- `--docker-server` - Docker Hub's registry URL
- `--docker-username` - Your Docker Hub username
- `--docker-password` - Your Docker Hub token
- `--namespace` - Create it in mini-finance-dev namespace

**Important Note:**
- Use the SAME token you created for GitHub Actions
- This ensures consistency across your CI/CD pipeline

**Verify it worked:**
```bash
kubectl get secret dockerhub-creds -n mini-finance-dev
```

---

### Step 5.2: Register Application with Argo CD

**File: `DevOps-Project-1/gitops/v5-app-project/app-project.yaml`**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
    name: finance-app-project
    namespace: argocd
spec:
    sourceRepos:
        - 'https://github.com/lakunzy7/expandox-lab.git'  # Allowed repositories
    destinations:
        - namespace: 'mini-finance-*'       # Can deploy to these namespaces
          server: 'https://kubernetes.default.svc'  # Can deploy to this cluster
    clusterResourceWhitelist:
        - group: ''
          kind: 'Namespace'  # Can create namespaces
    namespaceResourceWhitelist:
        - group: '*'
          kind: '*'  # Can create any resource in allowed namespaces
```

**What is this?**
- Defines a project in Argo CD
- Sets security/access rules for deploying applications

**Why do we need it?**
- Security: Only allow Argo CD to deploy from specific repositories
- Organization: Grouped related deployments together
- Control: Specify which namespaces and resources can be managed

**Apply it:**
```bash
kubectl apply -f DevOps-Project-1/gitops/v5-app-project/app-project.yaml
```

---

### Step 5.3: Define Applications with ApplicationSet

**File: `DevOps-Project-1/gitops/v6-application-sets/appset.yaml`**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
    name: mini-finance-appset
    namespace: argocd
spec:
    generators:
        - list:
            elements:
                - name: dev
                  namespace: mini-finance-dev
                  path: 'DevOps-Project-1/k8s/dev'
                - name: production
                  namespace: mini-finance-prod
                  path: 'DevOps-Project-1/k8s/production'
    
    template:
        metadata:
            name: 'mini-finance-{{name}}'
        spec:
            project: finance-app-project
            source:
                repoURL: 'https://github.com/lakunzy7/expandox-lab.git'
                targetRevision: HEAD
                path: '{{path}}'
            destination:
                server: 'https://kubernetes.default.svc'
                namespace: '{{namespace}}'
            syncPolicy:
                automated:
                    prune: true        # Delete resources removed from Git
                    selfHeal: true     # Revert manual changes
                syncOptions:
                    - CreateNamespace=true  # Create namespaces if they don't exist
```

**What is this?**
- An ApplicationSet that creates multiple Applications
- One Application for dev, one for production
- Automatically syncs when Git changes

**Why ApplicationSet instead of Application?**
- Reduces duplication (one template, multiple environments)
- Easier to maintain
- Follows DRY principle (Don't Repeat Yourself)

**How it works:**

The ApplicationSet **generates** two Applications:

**For Dev:**
```
Name: mini-finance-dev
Namespace: mini-finance-dev
Manifest Path: DevOps-Project-1/k8s/dev
```

**For Production:**
```
Name: mini-finance-production
Namespace: mini-finance-prod
Manifest Path: DevOps-Project-1/k8s/production
```

**syncPolicy: automated:**
- `prune: true` - If you remove something from Git, Argo CD removes it from cluster
- `selfHeal: true` - If someone manually changes the cluster, Argo CD fixes it back to Git state
- This ensures Git is always the source of truth

**Apply it:**
```bash
kubectl apply -f DevOps-Project-1/gitops/v6-application-sets/appset.yaml
```

**Verify:**
```bash
# List Argo CD applications
kubectl get applications -n argocd

# You should see:
# NAME                        STATUS  HEALTH
# mini-finance-dev            Synced  Healthy
# mini-finance-production     Synced  Healthy
```

---

## Part 6: Making Your First Deployment

### The Complete Flow (Step-by-Step)

Now that everything is set up, let's deploy for the first time.

### Step 6.1: Create Docker Hub Secret in Kubernetes (if not done already)

```bash
# For dev environment
kubectl create secret docker-registry dockerhub-creds \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=lakunzy \
  --docker-password=dckr_pat_xxxxxxxxxxxxxxxx \
  --namespace=mini-finance-dev

# For production environment  
kubectl create secret docker-registry dockerhub-creds \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=lakunzy \
  --docker-password=dckr_pat_xxxxxxxxxxxxxxxx \
  --namespace=mini-finance-prod
```

---

### Step 6.2: Set Up Argo CD

```bash
# 1. Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Register your Git repository
kubectl apply -f DevOps-Project-1/gitops/v2-add-cluster-and-repo/add-public-repo.yaml

# 3. Create the app project
kubectl apply -f DevOps-Project-1/gitops/v5-app-project/app-project.yaml

# 4. Create the applications
kubectl apply -f DevOps-Project-1/gitops/v6-application-sets/appset.yaml
```

**Verify everything is running:**
```bash
# Check Argo CD is running
kubectl get pods -n argocd

# Check applications are created
kubectl get applications -n argocd

# Check if namespaces were created
kubectl get namespaces | grep mini-finance
```

---

### Step 6.3: Make a Code Change and Deploy

Now for the exciting part - watch the entire pipeline work!

```bash
# 1. Make a change to your application code
cd DevOps-Project-1/mini-finance-app
echo "<!-- New change -->" >> index.html

# 2. Commit and push
git add .
git commit -m "feat: update homepage"
git push origin develop

# 3. Watch GitHub Actions build and push
# Go to GitHub → Actions tab
# You'll see: "CI - Build, Push, and Update Manifests" running
# It should take 1-2 minutes

# 4. Watch the manifest update
# GitHub Actions will automatically commit an update to:
# DevOps-Project-1/k8s/dev/manifests.yaml
# (You can see this in Git commit history)

# 5. Watch Argo CD sync
# Argo CD detects the manifest change
# It takes up to 3 minutes (default refresh interval)
# Or run: argocd app sync mini-finance-dev (requires Argo CD CLI)

# 6. Verify the new pod is running
kubectl get pods -n mini-finance-dev
kubectl describe pod <pod-name> -n mini-finance-dev  # See the new image tag
```

---

## Part 7: Monitoring & Troubleshooting

### Checking GitHub Actions Workflow

**Location:** GitHub → Actions tab

**What to look for:**

✅ **Success:**
```
✓ Checkout code
✓ Set up Docker Buildx
✓ Login to Docker Hub
✓ Build and Push Image
✓ Update Development Manifest
All checks passed
```

❌ **Common Failures:**

**"Username and password required"**
- Issue: Secrets not set up correctly
- Fix: Check GitHub Settings → Secrets:
  - `DOCKER_USERNAME` exists
  - `DOCKERHUB_TOKEN` exists
  - Values are correct (not empty)

**"Permission denied when pushing manifest"**
- Issue: Workflow doesn't have write permissions
- Fix: Check workflow file has:
  ```yaml
  permissions:
      contents: write
  ```

### Checking Argo CD Status

**List applications:**
```bash
kubectl get applications -n argocd
```

**Check detailed status:**
```bash
kubectl describe application mini-finance-dev -n argocd
```

**Look for these fields:**
- `Sync Status`: Should be `Synced` (not OutOfSync)
- `Health Status`: Should be `Healthy` (not Degraded)

**If OutOfSync:**
- Means Git and cluster are different
- Argo CD will automatically fix it (if syncPolicy.automated is true)
- Or manually: `kubectl patch application mini-finance-dev -n argocd -p '{"metadata":{"finalizers":null}}'`

---

### Checking Kubernetes Resources

**View pods:**
```bash
kubectl get pods -n mini-finance-dev
kubectl get pods -n mini-finance-prod
```

**See what image is running:**
```bash
kubectl get deployment mini-finance-app -n mini-finance-dev -o yaml | grep image:
```

**Check pod logs:**
```bash
kubectl logs -n mini-finance-dev -l app=mini-finance-app
```

**Check service:**
```bash
kubectl get service -n mini-finance-dev
```

---

### Troubleshooting Image Pull Issues

**Error: ImagePullBackOff**

```bash
# 1. Check if secret exists
kubectl get secret dockerhub-creds -n mini-finance-dev

# 2. Check secret contents
kubectl get secret dockerhub-creds -n mini-finance-dev -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq

# 3. Check if credentials are correct
# Compare with: echo $DOCKER_USERNAME, echo $DOCKER_TOKEN

# 4. Recreate the secret if credentials are wrong
kubectl delete secret dockerhub-creds -n mini-finance-dev
kubectl create secret docker-registry dockerhub-creds \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=your-username \
  --docker-password=your-token \
  --namespace=mini-finance-dev

# 5. Restart the pod
kubectl rollout restart deployment mini-finance-app -n mini-finance-dev
```

---

### Manually Syncing Applications

**If Argo CD is not syncing automatically:**

Option 1: Wait (default sync is every 3 minutes)
```bash
# Wait up to 3 minutes for automatic sync
```

Option 2: Manual sync (requires Argo CD CLI)
```bash
# Install Argo CD CLI (follow: https://argo-cd.readthedocs.io/en/stable/cli_installation/)

# Sync dev
argocd app sync mini-finance-dev

# Sync production
argocd app sync mini-finance-production
```

Option 3: Manual kubectl apply
```bash
# Apply manifests directly (not GitOps, but works in emergency)
kubectl apply -f DevOps-Project-1/k8s/dev/manifests.yaml
```

---

## Frequently Asked Questions

### Q1: What's the difference between a Deployment and a Pod?

**Pod:** The smallest unit in Kubernetes, runs a container
- Can have multiple containers
- Temporary (can be deleted and recreated)

**Deployment:** Manages Pods
- Ensures the right number of Pods are running
- Handles rolling updates (old pods → new pods)
- Automatically restarts failed pods

Think: Pod = single soldier, Deployment = squad of soldiers with a sergeant managing them

---

### Q2: Why do we need both GitHub Actions and Argo CD?

**GitHub Actions (CI - Build):**
- Builds Docker image
- Pushes to Docker Hub
- Updates manifest in Git

**Argo CD (CD - Deploy):**
- Watches Git for changes
- Automatically syncs to cluster
- Maintains desired state

They're complementary: GitHub Actions updates Git, Argo CD reacts to Git changes

---

### Q3: What if I want to deploy to production?

Simply push to the `main` branch instead of `develop`:

```bash
git checkout main
git pull origin main
# Make your changes
git commit -m "..."
git push origin main

# GitHub Actions will:
# - Build image
# - Update production/manifests.yaml
# - Argo CD will deploy to mini-finance-prod
```

---

### Q4: How do I know which image version is running?

```bash
# Check deployment
kubectl get deployment mini-finance-app -n mini-finance-dev -o yaml

# Look for the image line - it will show:
# image: lakunzy/mini-finance-app:abc123def456
# The abc123def456 is the commit SHA
```

---

### Q5: What if I break something in production?

**Option 1: Revert in Git**
```bash
git revert HEAD          # Reverts the last commit
git push origin main     # Argo CD automatically fixes cluster
```

**Option 2: Check Argo CD**
- Argo CD compares Git with cluster
- If you manually changed cluster, it reverts to Git state
- Git is always the source of truth

---

### Q6: Can I manually update something in the cluster?

Technically yes, but DON'T if Argo CD is managing it!

If you do:
```bash
kubectl edit deployment mini-finance-app -n mini-finance-dev
# Manual changes here
```

Argo CD will detect the difference and revert it (if `selfHeal: true`)

**Always make changes in Git, not in cluster directly!**

---

### Q7: How do I add a new environment (staging)?

1. Create manifest file: `DevOps-Project-1/k8s/staging/manifests.yaml`
2. Copy from dev, modify namespace to `mini-finance-staging`
3. Update ApplicationSet to include staging:
   ```yaml
   - name: staging
     namespace: mini-finance-staging
     path: 'DevOps-Project-1/k8s/staging'
   ```
4. Create secret: `kubectl create secret docker-registry dockerhub-creds ...`
5. Apply: `kubectl apply -f appset.yaml`

---

### Q8: What if the workflow fails?

1. Go to GitHub → Actions tab
2. Click the failed workflow
3. Read the error message carefully
4. Common issues:
   - Secrets not set up → Add them
   - No write permissions → Check permissions config
   - Docker Hub credentials wrong → Verify token is valid

---

### Q9: How often does Argo CD check for changes?

By default, every 3 minutes. 

To change it, edit the AppProject:
```yaml
spec:
  syncPolicy:
    syncInterval: 1m  # Check every 1 minute
```

---

### Q10: Why use GitOps instead of manual kubectl commands?

**Manual (Bad):**
```bash
kubectl set image deployment/mini-finance-app app=lakunzy/app:v2
# Only in your terminal's history
# Other team members don't know what changed
# If you lose your terminal history, you forgot how you deployed
# If cluster is recreated, settings are lost
```

**GitOps (Good):**
```bash
git push origin main
# Change is in Git history forever
# Entire team can see what changed and why
# Git commit is the audit trail
# If cluster is recreated, Argo CD reapplies from Git
# Any team member can see "why was it deployed this way"
```

---

## Summary: The Complete Journey

```
1. Developer writes code
   ↓
2. Developer pushes to GitHub
   ↓
3. GitHub Actions (CI) automatically:
   - Builds Docker image
   - Pushes to Docker Hub
   - Updates manifest in Git
   ↓
4. Git repository now has new image tag
   ↓
5. Argo CD (CD) automatically:
   - Detects the change
   - Compares with cluster state
   - Deploys new version
   ↓
6. Users see new version running!
```

**Every step is automated. Every change is audited. Git is the source of truth.**

---

## Next Steps

1. **Follow Part 3-6** exactly in order
2. **Test the workflow** by making a code change and pushing
3. **Monitor GitHub Actions** and Argo CD
4. **Celebrate** when your first automated deployment completes!
5. **Learn more** by reading the manifests and understanding each field

---

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs)
- [Docker Documentation](https://docs.docker.com)
- [Argo CD Documentation](https://argo-cd.readthedocs.io)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Happy Deploying! 🚀**