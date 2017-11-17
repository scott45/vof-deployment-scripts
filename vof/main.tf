provider "google" {
  credentials = "${file("${var.credential_file}")}"
  project = "${var.project_id}"
  region = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "vof"
    project = "vof-migration-test"
    credentials = "../shared/account.json"
  }
}

data "terraform_remote_state" "vof" {
  backend = "gcs"
  config {
    bucket = "vof"
    path = "${var.state_path}"
    project = "${var.project_id}"
    credentials = "${file("${var.credential_file}")}"
  }
}
