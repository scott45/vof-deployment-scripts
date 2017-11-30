output "instance-group-manager" {
  value = "${google_compute_instance_group_manager.vof-app-server-group-manager.name}"
}

output "new-instance-template" {
  value = "${google_compute_instance_template.vof-app-server-template.name}"
}

output "region" {
  value = "${var.region}"
}

output "zone" {
  value = "${var.zone}"
}