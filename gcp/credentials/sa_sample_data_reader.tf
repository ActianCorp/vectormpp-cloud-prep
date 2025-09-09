# This service account is used by VectorMPP Warehouses, which are Created by VectorMPP installations under GCP, to read GCS var.sampledata_bucket Bucket.
resource "google_service_account" "sample_data_reader" {
  account_id   = var.sa_sample_data_reader_name
  display_name = "Used by Warehouses to read Sample Data from GCS Bucket"
}

resource "google_storage_bucket_iam_member" "binding" {
  bucket = var.sampledata_bucket
  role   = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.sample_data_reader.email}"
}

