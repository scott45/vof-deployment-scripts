variable "elk_ip_cidr_range" {
  type = "string"
  default = "192.168.1.0/24"
}

variable "elk_region" {
  type = "string"
  default = "europe-west1"
}

variable "elk_reserved_env_ip" {
  type = "string"
}

variable "elk_machine_type" {
  type = "string"
  default = "n1-standard-1"
}

variable "elk_zone" {
  type = "string"
  default = "europe-west1-b"
}

variable "elk_service_account_email" {
  type = "string"
}

variable "elk_credential_file" {
  type = "string"
  default = "../shared/account.json"
}

variable "elk_project_id" {
  type = "string"
}

variable "elk_bucket" {
  type = "string"
}

variable "elk_state_path" {
  type = "string"
  default = "state/vof-elk-infra/terraform.tfstate"
}