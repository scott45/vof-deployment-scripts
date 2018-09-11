provider "google" {
  credentials = "${file("${var.jenkins_credential_file}")}"
  project     = "${var.jenkins_project_id}"
  region      = "${var.jenkins_region}"
}
