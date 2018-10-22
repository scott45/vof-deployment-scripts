output "self_link" {
  value = "${google_compute_network.network.self_link}"
}

output "private_network_name" {
  value = "${google_compute_subnetwork.private_sub_network.name}"
}

output "public_network_name" {
  value = "${google_compute_subnetwork.public_sub_network.name}"
}

output "network_name" {
  value = "${google_compute_network.network.name}"
}
