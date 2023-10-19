resource "google_compute_firewall" "default" {
  name    = "test-python"
  network = var.vpc_name
  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

