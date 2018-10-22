provider "google" {
  version     = "<= 1.17"
  credentials = "${file("${var.credential_file}")}"
  project     = "${var.google_project_id}"
  region      = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "apprenticeship"
    prefix = "vof/terraform"
  }
}

data "terraform_remote_state" "vof" {
  backend = "gcs"

  config {
    bucket      = "${var.vof_bucket}"
    project     = "${var.google_project_id}"
    credentials = "${file("${var.credential_file}")}"
  }
}
