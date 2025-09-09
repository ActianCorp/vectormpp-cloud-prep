resource "google_compute_network" "main" {
  name                    = var.cluster_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  network       = google_compute_network.main.id
  ip_cidr_range = "10.1.0.0/16"
}
