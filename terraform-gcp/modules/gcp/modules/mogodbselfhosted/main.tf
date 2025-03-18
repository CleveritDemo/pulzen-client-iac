# Deploy VM for mongodb commutity edition
resource "google_compute_instance" "mongodb_instance" {
  name         = var.app_name
  machine_type = var.vm_size
  zone         = var.zone
  tags         = ["mongodb"]

  boot_disk {
    initialize_params {
      image = "mongodb-community-10-ubuntu-2004"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
  
  metadata_startup_script = file("startup.sh")
}