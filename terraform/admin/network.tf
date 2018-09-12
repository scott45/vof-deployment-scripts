# Admin Network

module "network" {
  source                = "../modules/network"
  project_name          = "${var.project_name}"
  region                = "${var.region}"
  private_ip_cidr_range = "${var.private_ip_cidr_range}"
  public_ip_cidr_range  = "${var.public_ip_cidr_range}"
  environment           = "admin"
}
