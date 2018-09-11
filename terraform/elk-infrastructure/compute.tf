resource "google_compute_instance" "vof-elk-instance" {
  name         = "vof-elk-instance"
  machine_type = "${var.elk_machine_type}"
  zone         = "${var.elk_zone}"

  tags = ["http-server", "https-server", "vof-elk-instance"]

  boot_disk {
    initialize_params {
      image = "vof-elk-base-image"
    }
  }

  metadata {
    bucketName = "${var.elk_bucket}"
    startup-script = "/home/elk/start_elk.sh"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.vof-private-elk-subnetwork.name}"

    access_config {
      nat_ip = "${var.elk_reserved_env_ip}"
    }

  }

  service_account {
    email = "${var.elk_service_account_email}"

    scopes = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.read",
      "https://www.googleapis.com/auth/logging.write",
    ]
  }
}

resource "google_compute_firewall" "vof-elk-peer-traffic-firewall" {
  name    = "vof-elk-peer-firewall"
  network = "${google_compute_network.vof-elk-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/24", "10.1.0.0/24", "10.2.0.0/24"]
}

resource "google_compute_firewall" "vof-public-traffic-firewall" {
  name    = "vof-elk-public-firewall"
  network = "${google_compute_network.vof-elk-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
