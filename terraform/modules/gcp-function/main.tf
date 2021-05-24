resource "google_storage_bucket" "function_assets" {
  count    = var.create ? 1 : 0
  name     = "${var.name}-assets"
  location = var.region
}

resource "google_storage_bucket_object" "function_zipfile" {
  count  = var.create ? 1 : 0
  name   = "function.zip"
  bucket = google_storage_bucket.function_assets[0].name
  source = var.dist_file
}

resource "google_cloudfunctions_function" "this" {
  count                 = var.create ? 1 : 0
  name                  = "${var.name}-${regex("(?:[a-zA-Z](?:[-_a-zA-Z0-9]{0,61}[a-zA-Z0-9])?)", google_storage_bucket_object.function_zipfile[0].md5hash)}"
  runtime               = var.runtime
  available_memory_mb   = var.available_memory_mb
  timeout               = var.timeout
  source_archive_bucket = google_storage_bucket.function_assets[0].name
  source_archive_object = google_storage_bucket_object.function_zipfile[0].name
  entry_point           = var.entry_point
  trigger_http          = true
  labels                = var.labels
}

data "google_iam_policy" "function_policy" {
  count = var.create ? 1 : 0
  binding {
    role = "roles/cloudfunctions.invoker"
    members = [
      "allUsers"
    ]
  }
}

resource "google_cloudfunctions_function_iam_policy" "policy" {
  count          = var.create ? 1 : 0
  project        = google_cloudfunctions_function.this[0].project
  region         = google_cloudfunctions_function.this[0].region
  cloud_function = google_cloudfunctions_function.this[0].name
  policy_data    = data.google_iam_policy.function_policy[0].policy_data
}
