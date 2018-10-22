provider "google" {
  version     = "<= 1.17"
  credentials = "${file("${var.credential_file}")}"
  project     = "${var.google_project_id}"
  region      = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "apprenticeship"
    prefix = "shared-network/terraform"
  }
}

data "terraform_remote_state" "shared-network" {
  backend = "gcs"

  config {
    bucket      = "${var.bucket}"
    project     = "${var.google_project_id}"
    credentials = "${file("${var.credential_file}")}"
  }
}
