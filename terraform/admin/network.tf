# Admin Network

module "network" {
  source                = "../modules/network"
  project_name          = "${var.project_name}"
  region                = "${var.region}"
  private_ip_cidr_range = "${lookup(var.ip_cidr_ranges, "private_ip_cidr_range")}"
  public_ip_cidr_range  = "${lookup(var.ip_cidr_ranges, "public_ip_cidr_range")}"
  environment           = "admin"
}
