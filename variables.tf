variable "region" {
  type = "string"
  default = "europe-west1"
}

variable "db_instance_tier" {
  type = "string"
  default = "db-f1-micro"
}

variable "vof_host" {
  type = "string"
  default = ""
}

variable "project_id" {
  type = "string"
  default = ""
}

variable "db_username" {
  type = "string"
  default = ""
}

variable "credential_file" {
  type = "string"
  default = "/tmp/service-account.json"
}
