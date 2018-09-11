provider "google" {
  credentials = "${file("${var.elk_credential_file}")}"
  project = "${var.elk_project_id}"
  region = "${var.elk_region}"
}

terraform {
  backend "gcs" {
    credentials = "../shared/account.json"
  }
}

data "terraform_remote_state" "vof-elk" {
  backend = "gcs"
  config {
    bucket = "${var.elk_bucket}"
    path = "${var.elk_state_path}"
    project = "${var.elk_project_id}"
    credentials = "${file("${var.elk_credential_file}")}"
  }
}
