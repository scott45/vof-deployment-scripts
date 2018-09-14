# provider

variable "region" {
  type    = "string"
  default = "europe-west1"
}

variable "project_name" {}

variable "redis_domain" {
  default = "apprenticeship-redis.andela.com"
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

variable "bucket" {}

variable "base_image" {
  type    = "string"
  default = "ubuntu-1604-xenial-v20170815a"
}

variable "google_project_id" {
  type = "string"
}

variable "machine_types" {
  type = "map"

  default = {
    "standard" = "n1-standard-1"
    "small"    = "g1-small"
  }
}

variable "credential_file" {
  type    = "string"
  default = "../../../shared/account.json"
}

variable "environment" {
  type = "string"
}

variable "max_instances" {
  type = "map"

  default = {
    production = 3
    staging    = 1
    sandbox    = 1
  }
}

variable "min_instances" {
  type = "map"

  default = {
    production = 2
    staging    = 1
    sandbox    = 1
  }
}

variable "shared_database_instance_name" {
  type = "string"
}

variable "shared_database_instance_ip" {}

variable "health_checks_port" {
  default = "8080"
}

variable "disk_image" {
  type    = "string"
  default = "ubuntu-1604-xenial-v20180912"
}

variable "disk_type" {
  type    = "string"
  default = "pd-ssd"
}

variable "disk_size" {
  type    = "string"
  default = "10"
}

variable "request_path" {
  type    = "string"
  default = "/health"
}

variable "check_interval_sec" {
  type    = "string"
  default = "2"
}

variable "unhealthy_threshold" {
  type    = "string"
  default = "2"
}

variable "healthy_threshold" {
  type    = "string"
  default = "2"
}

variable "timeout_sec" {
  type    = "string"
  default = "1"
}

variable "db_username" {
  type    = "string"
  default = "daniel"
}

variable "db_replication_type" {
  type    = "string"
  default = "SYNCHRONOUS"
}

variable "db_backup_start_time" {
  type    = "string"
  default = "00:12"
}

variable "db_instance_tier" {
  type    = "string"
  default = "db-f1-micro"
}

variable "db_failover_target" {
  type    = "string"
  default = "true"
}

variable "db_connect_retry_interval" {
  type    = "string"
  default = "40"
}

variable "db_master_replica_name" {
  type    = "string"
  default = "vof-replica-master"
}

variable "db_master_replica_password" {
  type    = "string"
  default = "vof-replica"
}

variable "service_account_email" {
  type = "string"
}

variable "slack_webhook_url" {
  type = "string"
}

variable "slack_channel" {
  type = "string"
}

variable "cable_url" {
  type = "string"
}

variable "redis_ip" {
  type = "string"
}

variable "global_static_ip" {
  type = "string"
}

variable "ip_cidr_ranges" {
  type = "map"

  # TODO
  # Fix how cidr blocks are picked up
  default = {
    staging_private_ip_cidr_range = "10.10.0.0/24"
    staging_public_ip_cidr_range  = "10.12.0.0/24"
    sandbox_private_ip_cidr_range = "10.8.0.0/24"
    sandbox_public_ip_cidr_range  = "10.9.0.0/24"
  }
}

variable "database_host_ip" {
  type    = "string"
  default = ""
}

variable "bastion_host_ip" {
  type = "string"
}

variable "vof_bucket" {
  type    = "string"
  default = "apprenticeship"
}

variable "terraform_state_path" {
  type = "string"
}

variable "bugsnag_key" {}

variable "user_microservice_api_url" {}

variable "user_microservice_api_token" {}

variable "google_storage_access_key_id" {}

variable "google_storage_secret_access_key" {}

variable "db_backup_notification_token" {
  type = "string"
}
