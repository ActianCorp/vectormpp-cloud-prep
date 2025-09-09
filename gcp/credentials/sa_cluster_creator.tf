resource "google_service_account" "cluster_creator" {
  account_id   = var.sa_cluster_creator_name
  display_name = "VectorMPP Cluster Creator"
}

resource "google_project_iam_member" "cluster_creator_container_admin_role" {
  project = var.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_service_account_admin_role" {
  project = var.project
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_service_account_user_role" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_filestore_editor_role" {
  project = var.project
  role    = "roles/file.editor"
  member  = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_storage_admin_role" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_storage_object_admin_role" {
  project = var.project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_network_admin_role" {
  project = var.project
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_compute_storage_admin_role" {
  project = var.project
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_project_iam_admin" {
  project = var.project
  role   = "roles/resourcemanager.projectIamAdmin"
  member = "serviceAccount:${google_service_account.cluster_creator.email}"
}

resource "google_project_iam_member" "cluster_creator_sa_key_admin" {
  project = var.project
  role   = "roles/iam.serviceAccountKeyAdmin"
  member = "serviceAccount:${google_service_account.cluster_creator.email}"
}
