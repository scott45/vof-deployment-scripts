resource "google_compute_global_forwarding_rule" "vof-http" {
  name       = "${var.env_name}-vof-http"
  ip_address = "${var.reserved_env_ip}"
  target     = "${google_compute_target_http_proxy.vof-http-proxy.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "vof-http-proxy" {
  name        = "${var.env_name}-vof-proxy"
  url_map     = "${google_compute_url_map.vof-http-url-map.self_link}"
}

resource "google_compute_url_map" "vof-http-url-map" {
  name            = "${var.env_name}-vof-url-map"
  default_service = "${google_compute_backend_service.web.self_link}"

  host_rule {
    hosts        = ["${var.reserved_env_ip}"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.web.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.web.self_link}"
    }
  }
}

resource "google_compute_firewall" "vof-internal-firewall" {
  name = "${var.env_name}-vof-internal-network"
  network = "${google_compute_network.vof-network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }

  source_ranges = ["${var.ip_cidr_range}", "${google_compute_instance.vof-jumpbox.network_interface.0.access_config.0.assigned_nat_ip}"]
}

resource "google_compute_firewall" "vof-public-firewall" {
  name = "${var.env_name}-vof-public-firewall"
  network = "${google_compute_network.vof-network.name}"

  allow {
    protocol = "tcp"
    ports = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${var.env_name}-vof-lb"]
}

resource "google_compute_firewall" "vof-allow-healthcheck-firewall" {
  name = "${var.env_name}-vof-allow-healthcheck-firewall"
  network = "${google_compute_network.vof-network.name}"

  allow {
    protocol = "tcp"
    ports = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags = ["${var.env_name}-vof-app-server", "vof-app-server"]
}
