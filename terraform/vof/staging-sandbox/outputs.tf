output "instance-group-manager" {
  value = "${google_compute_instance_group_manager.manager.name}"
}

output "instance-template" {
  value = "${google_compute_instance_template.template.name}"
}

output "region" {
  value = "${var.region}"
}

output "zone" {
  value = "${var.zone}"
}
