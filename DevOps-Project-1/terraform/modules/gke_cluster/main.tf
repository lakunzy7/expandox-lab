provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.region
  deletion_protection      = false
  remove_default_node_pool = false
  initial_node_count       = var.node_count
  network                  = var.vpc_network
  subnetwork               = var.vpc_subnetwork

  # Further production hardening would include:
  # - private_cluster_config
  # - release_channel
  # - network_policy
  # - logging_service/monitoring_service
}
