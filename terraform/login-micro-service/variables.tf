variable "login_microservice_region" {
  type = "string"
  default = "europe-west1"
}

variable "login_microservice_project_id" {
  type = "string"
  default = "andela-learning"
}

variable "login_microservice_env_name" {
  type = "string"
}

variable "login_microservice_db_instance_tier" {
  type = "string"
  default = "db-f1-micro"
}

variable "login_microservice_db_backup_start_time" {
  type = "string"
  default = "00:12"
}

variable "login_microservice_credential_file" {
  type = "string"
  default = "../shared/account.json"
}

variable "login_microservice_state_path" {
  type = "string"
}

variable "login_microservice_bucket" {
  type = "string"
}
