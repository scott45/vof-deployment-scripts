resource "google_compute_network" "jenkins-network" {
  name = "jenkins-network"
}

resource "google_compute_subnetwork" "jenkins-private-subnetwork" {
  name          = "jenkins-private-subnetwork"
  region        = "${var.jenkins_region}"
  network       = "${google_compute_network.jenkins-network.self_link}"
  ip_cidr_range = "${var.jenkins_ip_cidr_range}"
}
