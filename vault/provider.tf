# Configure the Google Cloud provider
provider "google" {
    credentials = "${file("${var.account_file}")}"
    project = "${var.google_project_id}"
    region = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "vof"
    project = "vof-migration-test"
    credentials = "../shared/account.json"
  }
}

data "terraform_remote_state" "vault" {
  backend = "gcs"
  config {
    bucket = "vof"
    path = "${var.state_path}" # state/vault/terraform.tfstate
    project = "${var.google_project_id}"
    credentials = "${file("${var.account_file}")}"
  }
}