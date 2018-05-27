variable "region" {
  type = "string"
  default = "europe-west1"
}

variable "zone" {
  type = "string"
  default = "europe-west1-b"
}

variable "reserved_env_ip" {}

variable "bucket" {}

variable "base_image" {
  type = "string"
  default = "ubuntu-1604-xenial-v20170815a"
}

variable "project_id" {
  type = "string"
  default = "vof-migration-test"
}

variable "machine_type" {
  type = "string"
  default = "n1-standard-1"
}

variable "small_machine_type" {
  type = "string"
  default = "g1-small"
}

variable "credential_file" {
  type = "string"
  default = "../shared/account.json"
}

variable "env_name" {
  type = "string"
}

variable "state_path" {
  type = "string"
}

variable "max_instances" {
  type = "string"
  default = "4"
}

variable "min_instances" {
  type = "string"
  default = "2"
}

variable "vof_disk_image" {
  type = "string"
}

variable "vof_disk_type" {
  type = "string"
  default = "pd-ssd"
}

variable "vof_disk_size" {
  type = "string"
  default = "10"
}

variable "request_path" {
  type = "string"
  default = "/login"
}

variable "check_interval_sec" {
  type = "string"
  default = "2"
}

variable "unhealthy_threshold" {
  type = "string"
  default = "2"
}

variable "healthy_threshold" {
  type = "string"
  default = "2"
}

variable "timeout_sec" {
  type = "string"
  default = "1"
}

variable "ip_cidr_range" {
  type = "string"
  default = "10.0.0.0/24"
}

variable "staging_ip_cidr_range" {
  type = "string"
  default = "10.1.0.0/24"
}

variable "sandbox_ip_cidr_range" {
  type = "string"
  default = "10.2.0.0/24"
}

variable "ip_cidr_range_next" {
  type = "string"
  default = "10.0.1.0/24"
}

variable "staging_ip_cidr_range_next" {
  type = "string"
  default = "10.1.1.0/24"
}

variable "sandbox_ip_cidr_range_next" {
  type = "string"
  default = "10.2.1.0/24"
}

variable "db_username" {
  type = "string"
  default = "daniel"
}

variable "db_replication_type" {
  type = "string"
  default = "SYNCHRONOUS"
}

variable "db_backup_start_time" {
  type = "string"
  default = "00:12"
}

variable "db_instance_tier" {
  type = "string"
  default = "db-f1-micro"
}

variable "db_failover_target" {
  type = "string"
  default = "true"
}

variable "db_connect_retry_interval" {
  type = "string"
  default = "40"
}

variable "db_master_replica_name" {
  type = "string"
  default = "vof-replica-master"
}

variable "db_master_replica_password" {
  type = "string"
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

variable "bugsnag_key" {}

variable "user_microservice_api_url" {}

variable "user_microservice_api_token" {}
