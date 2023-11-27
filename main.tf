terraform {
 backend "gcs" {
   bucket  = "itoutposts"
   prefix  = "terraform/state/gke"
 }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.28."
}

resource "google_container_cluster" "primary" {
  name     = "itoutposts-gke"
  location = var.region
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.gke_network.name
  subnetwork = google_compute_subnetwork.gke_subnetwork.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project
    }

    # preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 20
    tags         = ["gke-node", "itoutposts-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}