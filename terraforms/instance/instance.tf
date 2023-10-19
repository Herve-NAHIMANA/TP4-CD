resource "google_compute_instance" "computer_engine" {
  name =  "instance-${var.instance_name}"
  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = var.image_disk
      labels = {
        my_label = "value"
      }
    }
  }

   network_interface {
    network = var.vpc_name
    subnetwork = var.subnet_name

    access_config {
      // Ephemeral public IP
    }
  }

}