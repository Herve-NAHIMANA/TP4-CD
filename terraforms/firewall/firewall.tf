resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = var.vpc_name
  allow {
    protocol = "tcp"
    ports    = ["80","22","443"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "mysql_firwall" {
  name    = "mysql-firwall"
  network = var.vpc_name
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_ranges = ["10.2.0.0/16"]
}

