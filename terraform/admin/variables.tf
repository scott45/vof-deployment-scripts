variable "ip_cidr_ranges" {
  type    = "list"
  default = ["192.168.1.0/24"]
}

variable "private_ip_cidr_range" {
  description = "Google compute private network cidr notation"
}

variable "public_ip_cidr_range" {
  description = "Google compute public network cidr notation"
}

variable "region" {
  type    = "string"
  default = "europe-west1"
}

variable "elk_reserved_env_ip" {
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
  default = "../shared/account.json"
}

variable "google_project_id" {
  type = "string"
}

variable "admin_bucket" {
  type = "string"
}

variable "terraform_state_path" {
  type    = "string"
  default = "state/admin/terraform.tfstate"
}

variable "project_name" {
  description = "Google compute project name"
}
