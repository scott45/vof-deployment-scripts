resource "google_compute_network_peering" "peering" {
  name         = "${var.name}"
  network      = "${var.network}"
  peer_network = "${var.peer_network}"
}
