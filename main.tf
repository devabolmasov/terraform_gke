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
  version_prefix = "1.27."
}

resource "google_container_cluster" "primary" {
  name     = "itoutposts-gke"
  location = var.zone
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.gke_network.name
  subnetwork = google_compute_subnetwork.gke_subnetwork.name

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  max_pods_per_node = 50
  version = data.google_container_engine_versions.gke_version.default_cluster_version
  
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
    machine_type = var.machine_type
    disk_size_gb = 20
    tags         = ["gke-node"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
