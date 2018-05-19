provider "google" {
  credentials = "${file("${var.login_microservice_credential_file}")}"
  project = "${var.login_microservice_project_id}"
  region = "${var.login_microservice_region}"
}

terraform {
  backend "gcs" {
    credentials = "../shared/account.json"
  }
}

data "terraform_remote_state" "vof" {
  backend = "gcs"
  config {
    bucket = "${var.login_microservice_bucket}"
    path = "${var.login_microservice_state_path}"
    project = "${var.login_microservice_project_id}"
    credentials = "${file("${var.login_microservice_credential_file}")}"
  }
}
