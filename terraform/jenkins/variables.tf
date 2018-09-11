variable "jenkins_region" {
  type    = "string"
  default = "europe-west1"
}

variable "jenkins_zone" {
  type    = "string"
  default = "europe-west1-b"
}

//variable "jenkins_reserved_env_ip" {}

variable "jenkins_base_image" {
  type    = "string"
  default = "jenkins-master-image-1526586788"
}

variable "jenkins_project_id" {
  type    = "string"
  default = "andela-learning"
}

variable "jenkins_credential_file" {
  type    = "string"
  default = "../../shared/account.json"
}

variable "jenkins_ip_cidr_range" {
  type    = "string"
  default = "10.0.0.0/24"
}

variable "jenkins_service_account_email" {
  type    = "string"
  default = "vof-15@andela-learning.iam.gserviceaccount.com"
}

variable "jenkins_machine_type" {
  type    = "string"
  default = "n1-standard-1"
}
