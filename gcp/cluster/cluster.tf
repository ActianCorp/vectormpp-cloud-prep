resource "google_service_account" "default" {
  account_id   = "${var.cluster_name}"
  display_name = "sa for ${var.cluster_name}"
}

resource "google_container_cluster" "main" {
  name = var.cluster_name
  location = var.cluster_location
  node_locations = [var.node_location]
  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.subnet.name
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  addons_config {
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  resource_labels = {
    belongto = "vectormpp"
  }
}

resource "google_container_node_pool" "main" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.cluster_location
  cluster    = google_container_cluster.main.id
  initial_node_count = var.min_node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    service_account = google_service_account.default.email
    preemptible  = false
    image_type = "UBUNTU_CONTAINERD"
    machine_type = var.node_type
    disk_size_gb = "500"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    resource_labels = {
      belongto = "vectormpp"
    }
  }
}
