resource "google_compute_network" "gke_network" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnetwork" {
  name          = "gke-subnetwork"
  ip_cidr_range = var.subnet_cidr_block
  region        = var.region
  network       = google_compute_network.gke_network.id

}