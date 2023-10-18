resource "google_service_account" "service_account" {
  account_id   = var.account
  display_name = var.account
}
resource "google_service_account_key" "service_account" {
  service_account_id = google_service_account.service_account.name
  public_key_type    = var.key_type
}
resource "local_file" "service_account" {
    content  = base64decode(google_service_account_key.service_account.private_key)
    filename = "../ansible/${var.file_name}"
}
resource "google_project_iam_binding" "project" {
  project = var.gcp_project
  role    = "roles/viewer"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}


