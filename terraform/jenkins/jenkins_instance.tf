resource "google_compute_instance" "jenkins-instance" {
  name         = "jenkins-instance"
  machine_type = "${var.jenkins_machine_type}"
  zone         = "${var.jenkins_zone}"

  tags = ["jenkins-instance"]

  boot_disk {
    initialize_params {
      image = "${var.jenkins_base_image}"
    }
  }

  network_interface {
    network = "${google_compute_network.jenkins-network.name}"

    access_config = {
      nat_ip = "35.189.212.56"
    }
  }

  metadata {
    serviceAccountEmail = "${var.jenkins_service_account_email}"
    serial-port-enable  = 1
  }

  service_account {
    email  = "${var.jenkins_service_account_email}"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_firewall" "jenkins_instance_firewall" {
  name    = "jenkins-instance-firewall"
  network = "${google_compute_network.jenkins-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins-instance"]
}
