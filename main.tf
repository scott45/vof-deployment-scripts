provider "google" {
  credentials = "${file("${var.credential_file}")}"
  project = "${var.project_id}"
  region = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "some-bucket"
    path = "/path/to/state/file"
    project = "some-project-id"
    credentials = <<JSON
JSON
  }
}

data "terraform_remote_state" "vof" {
  backend = "gcs"
  config {
    bucket = "some-bucket"
    path = "/path/to/state/file"
    project = "some-project-id"
    credentials = <<JSON
JSON
  }
}
