resource "google_compute_network" "network" {
  name                    = "${format("%s-%-network", var.project_name, var.environment)}"
  auto_create_subnetworks = "${var.auto_create_subnetworks}"
}

resource "google_compute_subnetwork" "private_sub_network" {
  name          = "${format("%s-%s-private-sub-network", var.project_name,var.environment)}"
  region        = "${var.region}"
  network       = "${google_compute_network.network.self_link}"
  ip_cidr_range = "${var.private_ip_cidr_range}"
}

resource "google_compute_subnetwork" "public_sub_network" {
  name          = "${format("%s-%s-public-sub-network", var.project_name,var.environment)}"
  region        = "${var.region}"
  network       = "${google_compute_network.network.self_link}"
  ip_cidr_range = "${var.public_ip_cidr_range}"
}
