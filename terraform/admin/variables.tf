variable "ip_cidr_ranges" {
  type = "map"

  default = {
    private_ip_cidr_range = "10.2.0.0/24"
    public_ip_cidr_range  = "10.3.0.0/24"
  }
}

variable "region" {
  type    = "string"
  default = "europe-west1"
}

variable "elk_reserved_static_ip" {
  type = "string"
}

variable "machine_types" {
  type = "map"

  default = {
    "standard" = "n1-standard-1"
    "small"    = "g1-small"
  }
}

variable "zone" {
  type    = "string"
  default = "europe-west1-b"
}

variable "service_account_email" {
  type = "string"
}

variable "credential_file" {
  type    = "string"
  default = "../../shared/account.json"
}

variable "google_project_id" {
  type = "string"
}

variable "admin_bucket" {
  type    = "string"
  default = "apprenticeship"
}

variable "terraform_state_path" {
  type    = "string"
  default = "admin/terraform/default.tfstate"
}

variable "project_name" {
  description = "Google compute project name"
}

variable "bastion_image" {
  default = "ubuntu-1604-xenial-v20180912"
}

variable "elk_source_ranges" {
  default = ["0.0.0.0/0"]
}

variable "elk_server_image" {
  default = "ubuntu-1604-xenial-v20180912"
}

variable "redis_server_image" {
  default = "ubuntu-1604-xenial-v20180912"
}
