# Main Network

module "network" {
  source                = "../../modules/network"
  project_name          = "${var.project_name}"
  region                = "${var.region}"
  private_ip_cidr_range = "${lookup(var.ip_cidr_ranges, "${format("%s_private_ip_cidr_range", var.environment)}")}"
  public_ip_cidr_range  = "${lookup(var.ip_cidr_ranges, "${format("%s_public_ip_cidr_range", var.environment)}")}"
  environment           = "${var.environment}"
}

module "project_network" {
  source = "../../modules/network/peering"

  # vof-production-to-admin-network-peering
  name         = "${format("%s-%s-to-admin-network-peering", var.project_name, var.environment)}"
  network      = "${module.network.self_link}"
  peer_network = "${format("projects/%s/global/networks/%s", var.google_project_id, var.admin_peer_network_name)}"
}

module "admin_network" {
  source = "../../modules/network/peering"

  # admim-to-vof-production-network-peering
  name         = "${format("admin-to-%s-%s-network-peering", var.project_name, var.environment)}"
  network      = "${format("projects/%s/global/networks/%s", var.google_project_id, var.admin_peer_network_name)}"
  peer_network = "${module.network.self_link}"
}
