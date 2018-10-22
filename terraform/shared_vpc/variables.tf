# provider

variable "region" {
  type    = "string"
  default = "europe-west1"
}

variable "project_name" {
  type = "string"
}

variable "zone" {
  type    = "string"
  default = "europe-west1-b"
}

# network
variable "admin_peer_network_name" {
  description = "Google compute network name"
  default     = "apprenticeship-admin-network"
}

variable "google_project_id" {
  type = "string"
}

variable "credential_file" {
  type    = "string"
  default = "../../shared/account.json"
}

variable "environment" {
  type = "string"
}

variable "service_account_email" {
  type = "string"
}

variable "bucket" {
  type    = "string"
  default = "apprenticeship"
}
