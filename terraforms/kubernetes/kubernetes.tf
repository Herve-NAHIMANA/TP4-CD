resource "google_container_cluster" "my_cluster" {
  name               = "my-gke-cluster"
  location           = var.gcp_region  # Modifiez la région selon vos besoins
  network = var.vpc_name
  subnetwork = var.subnet_name
  project = var.gcp_project
  initial_node_count = 3
  node_config {
    preemptible  = false
    machine_type = "n1-standard-2"  # Modifiez le type de machine selon vos besoins
  }
}