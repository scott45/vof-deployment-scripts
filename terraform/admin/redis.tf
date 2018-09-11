resource "google_compute_address" "redis-ip" {
  name   = "${var.env_name}-redis-ip"
  region = "${var.region}"
}

resource "google_compute_instance" "vof-redis-server" {
  name         = "${var.env_name}-vof-redis-server"
  machine_type = "${var.small_machine_type}"
  zone         = "${var.zone}"

  tags = ["http-server", "https-server", "${var.env_name}-redis-server"]

  boot_disk {
    initialize_params {
      image = "vof-redis-server-base-image"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.vof-subnetwork.name}"

    access_config {
      // Ephemeral IP
      nat_ip = "${google_compute_address.redis-ip.address}"
    }

  }

  service_account {
    email = "${var.service_account_email}"

    scopes = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.read",
      "https://www.googleapis.com/auth/logging.write",
    ]
  }
}

resource "google_compute_firewall" "vof-redis-traffic-firewall" {
  name    = "vof-${var.env_name}-redis-firewall"
  network = "${google_compute_network.vof-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["1025-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.env_name}-redis-server"]
}
