resource "google_compute_subnetwork" "Test" {
  name          = var.subnet_name
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-east1"
  network       = google_compute_network.custom-test.id
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.0.1.0/28"
  }

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.0.1.16/28"
  }
}
resource "google_compute_network" "custom-test" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}