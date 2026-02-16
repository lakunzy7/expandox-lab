provider "google" {
  project = "payday-project-487110"
  region  = "us-central1"
}

module "gke_cluster" {
  source = "../../modules/gke_cluster"

  project_id     = "payday-project-487110" # Replace with your GCP project ID
  cluster_name   = "payday-staging-cluster"
  vpc_network    = module.vpc.network_id
  vpc_subnetwork = module.vpc.subnetwork_id
  node_count     = 1
  machine_type   = "e2-medium"
}

module "vpc" {
  source = "../../modules/vpc"
  # Add VPC variables here
}
