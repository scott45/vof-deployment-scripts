resource "google_compute_network" "vof-network" {
  name = "${var.env_name}-vof-network"
}

resource "google_compute_subnetwork" "vof-private-subnetwork" {
  name = "${var.env_name}-vof-private-subnetwork"
  region = "${var.region}"
  network = "${google_compute_network.vof-network.self_link}"
  ip_cidr_range = "${var.ip_cidr_range}"
}
