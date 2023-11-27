resource "google_compute_firewall" "allow-ssh" {
  project = "premium-guide-403909"
  name    = "gke-ssh"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Allow SSH access from any IP address (for demonstration purposes, you may want to restrict this to a specific IP range)
}

resource "google_compute_firewall" "allow-http-https" {
  name    = "gke-http-s"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  

  source_ranges = ["0.0.0.0/0"] # Allow HTTP access from any IP address (for demonstration purposes, you may want to restrict this to a specific IP range)
}
