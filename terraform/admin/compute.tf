resource "google_compute_instance" "elk_instance" {
  name         = "${format("%s-elk-instance", var.project_name)}"
  machine_type = "${lookup(var.machine_types, "standard")}"
  zone         = "${var.zone}"

  tags = [
    "http-server",
    "https-server",
    "${var.project_name}-elk-instance",
  ]

  boot_disk {
    initialize_params {
      image = "${var.elk_server_image}"
    }
  }

  metadata {
    bucketName     = "${var.admin_bucket}"
    startup-script = "/home/elk/start_elk.sh"
  }

  network_interface {
    subnetwork = "${module.network.private_network_name}"

    access_config {
      nat_ip = "${google_compute_address.elk_ip.address}"
    }
  }

  service_account {
    email = "${var.service_account_email}"

    scopes = [
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.read",
      "https://www.googleapis.com/auth/logging.write",
    ]
  }
}

resource "google_compute_firewall" "elk_peer_traffic" {
  name    = "${format("%s-elk-peer-firewall", var.project_name)}"
  network = "${module.network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["${var.elk_source_ranges}"]
}

resource "google_compute_firewall" "elk_public_traffic" {
  name    = "${format("%s-elk-public-firewall", var.project_name)}"
  network = "${module.network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Redis configurations
resource "google_compute_instance" "redis" {
  name         = "${format("%s-redis-server", var.project_name)}"
  machine_type = "${lookup(var.machine_types, "small")}"
  zone         = "${var.zone}"

  tags = [
    "http-server",
    "https-server",
    "${var.project_name}-redis-server",
  ]

  boot_disk {
    initialize_params {
      image = "${var.redis_server_image}"
    }
  }

  network_interface {
    subnetwork = "${module.network.public_network_name}"

    access_config {
      # Ephemeral IP
      nat_ip = "${google_compute_address.redis_ip.address}"
    }
  }

  service_account {
    email = "${var.service_account_email}"

    scopes = [
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.read",
      "https://www.googleapis.com/auth/logging.write",
    ]
  }
}

resource "google_compute_address" "redis_ip" {
  name   = "${format("%s-redis-ip", var.project_name)}"
  region = "${var.region}"
}

resource "google_compute_address" "elk_ip" {
  name   = "${format("%s-elk-ip", var.project_name)}"
  region = "${var.region}"
}

resource "google_compute_firewall" "redis_traffic" {
  name    = "${format("%s-redis-firewall", var.project_name)}"
  network = "${module.network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["1025-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${format("%s-redis-server", var.project_name)}"]
}

# Bastion Host
resource "google_compute_instance" "bastion_host" {
  name         = "${format("%s-bastion-host", var.project_name)}"
  machine_type = "${lookup(var.machine_types, "small")}"
  zone         = "${var.zone}"

  tags = ["${format("%s-bastion-host", var.project_name)}"]

  boot_disk {
    initialize_params {
      image = "${var.bastion_image}"
    }
  }

  network_interface {
    subnetwork    = "${module.network.public_network_name}"
    access_config = {}
  }

  metadata {
    serviceAccountEmail = "${var.service_account_email}"
    serial-port-enable  = 1
  }

  service_account {
    email  = "${var.service_account_email}"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_firewall" "bastion_host" {
  name    = "${format("%s-bastion-host-firewall", var.project_name)}"
  network = "${module.network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${format("%s-bastion-host", var.project_name)}"]
}
