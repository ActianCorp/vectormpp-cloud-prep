# This service account is used by data-plane pod in All the VectorMPP installations.
# e.g. create gcs bucket for warehouses.
resource "google_service_account" "data_plane" {
  account_id   = var.sa_data_plane_name
  display_name = "VectorMPP Data-Plane"
}

resource "google_project_iam_member" "data_plane_service_account_admin_role" {
  project = var.project
  role    = "roles/iam.serviceAccountAdmin"
  member = "serviceAccount:${google_service_account.data_plane.email}"
}

resource "google_project_iam_member" "data_plane_storage_admin_role" {
  project = var.project
  role    = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.data_plane.email}"
}

resource "google_project_iam_member" "data_plane_storage_hmackey_admin_role" {
  project = var.project
  role    = "roles/storage.hmacKeyAdmin"
  member = "serviceAccount:${google_service_account.data_plane.email}"
}

# member must keep it as-is, vectormpp-dataplane/agent is hardcoded in VectorMPP code.
resource "google_service_account_iam_member" "ksa_binding" {
  service_account_id = google_service_account.data_plane.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[vectormpp-dataplane/agent]"
}

