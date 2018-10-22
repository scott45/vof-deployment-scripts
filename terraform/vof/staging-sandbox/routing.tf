# Begin HTTP
resource "google_compute_global_forwarding_rule" "http" {
  # vof-production-http
  name       = "${format("%s-%s-http", var.project_name, var.environment)}"
  ip_address = "${google_compute_global_address.global_static_ip.address}"
  target     = "${google_compute_target_http_proxy.http-proxy.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "http-proxy" {
  # vof-production-proxy
  name    = "${format("%s-%s-proxy", var.project_name, var.environment)}"
  url_map = "${google_compute_url_map.http-url-map.self_link}"
}

# End HTTP

# Begin HTTPS
resource "google_compute_global_forwarding_rule" "https" {
  # vof-production-https
  name       = "${format("%s-%s-https", var.project_name, var.environment)}"
  ip_address = "${google_compute_global_address.global_static_ip.address}"
  target     = "${google_compute_target_https_proxy.https-proxy.self_link}"
  port_range = "443"
}

resource "google_compute_ssl_certificate" "ssl-certificate" {
  name_prefix = "${var.project_name}-certificate-"
  description = "${upper(var.project_name)} HTTPS certificate"
  private_key = "${file("../../../shared/andela_key.key")}"
  certificate = "${file("../../../shared/andela_certificate.crt")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_https_proxy" "https-proxy" {
  name             = "${format("%s-%s-https-proxy", var.project_name, var.environment)}"
  url_map          = "${google_compute_url_map.http-url-map.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.ssl-certificate.self_link}"]
}

# End HTTPS

resource "google_compute_url_map" "http-url-map" {
  name            = "${format("%s-%s-http-url-map", var.project_name, var.environment)}"
  default_service = "${google_compute_backend_service.web.self_link}"

  host_rule {
    hosts        = ["${google_compute_global_address.global_static_ip.address}"]
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

resource "google_compute_firewall" "internal-firewall" {
  name    = "${format("%s-%s-internal-network", var.project_name, var.environment)}"
  network = "${format("shared-%s-network", var.environment)}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    "${lookup(var.ip_cidr_ranges, "${format("%s-%s-private-ip-cidr-range", var.project_name, var.environment)}")}",
    "${lookup(var.ip_cidr_ranges, "${format("%s-%s-public-ip-cidr-range", var.project_name, var.environment)}")}",
    "${var.bastion_host_ip}",
  ]
}

resource "google_compute_firewall" "public-firewall" {
  # vof-production-public-firewall
  name    = "${format("%s-%s-public-firewall", var.project_name, var.environment)}"
  network = "${format("shared-%s-network", var.environment)}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${format("%s-%s-loadbalancer", var.project_name, var.environment)}"]
}

resource "google_compute_firewall" "allow-healthcheck-firewall" {
  name    = "${format("%s-%s-allow-healthcheck-firewall", var.project_name, var.environment)}"
  network = "${format("shared-%s-network", var.environment)}"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  target_tags = [
    # vof-production-app-server
    "${format("%s-%s-app-server", var.project_name, var.environment)}",

    "${var.project_name}-app-server",
  ]
}
