provider "google" {
    project = var.project_id
    region  = var.region
}

data "google_compute_zones" "available_zones" {}

resource "google_compute_address" "static" {
  name = "apache"
}

resource "google_compute_instance" "apache" {
  name = "apache"
  zone = data.google_compute_zones.available_zones.names[0]
  tags = ["allow-http","http-server"]
  

  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20240927"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata_startup_script = file("startup_script.sh")
}

resource "google_compute_firewall" "allow_http" {
    name = "allow-http-rule"
    network = "default"
    
    allow {
      ports = ["80"]
      protocol = "tcp"
    }

    target_tags = ["allow-http"]
    source_ranges = ["0.0.0.0/0"]

    priority = 1000
  
}

output "public_ip_address" {
  value = google_compute_address.static.address
}