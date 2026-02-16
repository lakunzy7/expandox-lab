variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for the cluster."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "vpc_network" {
  description = "The VPC network for the cluster."
  type        = string
}

variable "vpc_subnetwork" {
  description = "The VPC subnetwork for the cluster."
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the node pool."
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "The machine type for the nodes."
  type        = string
  default     = "e2-medium"
}
