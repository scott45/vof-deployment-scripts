provider "google" {
  credentials = "${file("${var.credential_file}")}"
  project     = "${var.google_project_id}"
  region      = "${var.region}"
}

terraform {
  backend "gcs" {
    credentials = "../shared/account.json"
  }
}

data "terraform_remote_state" "admin" {
  backend = "gcs"

  config {
    bucket      = "${var.admin_bucket}"
    path        = "${var.terraform_state_path}"
    project     = "${var.google_project_id}"
    credentials = "${file("${var.credential_file}")}"
  }
}
