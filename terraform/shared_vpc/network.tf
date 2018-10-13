# Main Network

resource "google_compute_network" "shared-network" {
  name                    = "${format("shared-%s-network", var.environment)}"
  auto_create_subnetworks = "false"
}

module "project_network" {
  source = "../modules/network/peering"

  # shared-vpc-staging-to-admin-network-peering
  name         = "${format("%s-%s-to-admin-network-peering", var.project_name, var.environment)}"
  network      = "${google_compute_network.shared-network.self_link}"
  peer_network = "${format("projects/%s/global/networks/%s", var.google_project_id, var.admin_peer_network_name)}"
}

module "admin_network" {
  source = "../modules/network/peering"

  # admim-to-shared-vpc-staging-network-peering
  name         = "${format("admin-to-%s-%s-network-peering", var.project_name, var.environment)}"
  network      = "${format("projects/%s/global/networks/%s", var.google_project_id, var.admin_peer_network_name)}"
  peer_network = "${google_compute_network.shared-network.self_link}"
}
