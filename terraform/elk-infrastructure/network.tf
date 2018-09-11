resource "google_compute_network" "vof-elk-network" {
  name = "vof-elk-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "vof-private-elk-subnetwork" {
  name = "vof-private-elk-subnetwork"
  region = "${var.elk_region}"
  network = "${google_compute_network.vof-elk-network.self_link}"
  ip_cidr_range = "${var.elk_ip_cidr_range}"

}
