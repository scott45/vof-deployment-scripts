resource "google_compute_backend_service" "web" {
  name = "${var.env_name}-vof-lb"
  description = "VOF Load Balancer"
  port_name = "customhttp"
  protocol = "HTTP"
  enable_cdn = false

  backend {
    group = "${google_compute_instance_group_manager.vof-app-server-group-manager.instance_group}"
  }

  health_checks = ["${google_compute_http_health_check.vof-app-healthcheck.self_link}"]
}

resource "google_compute_instance_group_manager" "vof-app-server-group-manager" {
  name = "${var.env_name}-vof-app-server-group-manager"
  base_instance_name = "${var.env_name}-vof-app-instance"
  instance_template = "${google_compute_instance_template.vof-app-server-template.self_link}"
  zone = "${var.zone}"
  update_strategy = "NONE"
  target_size = 1

  named_port {
    name = "customhttp"
    port = 8080
  }
}

resource "google_compute_instance_template" "vof-app-server-template" {
  name = "${var.env_name}-vof-app-server-template"
  machine_type = "${var.machine_type}"
  region = "${var.region}"
  description = "Base template to create VOF instances"
  instance_description = "Instance created from base template"
  depends_on = ["google_sql_database_instance.vof-database-instance", "random_id.vof-db-user-password"]
  tags = ["${var.env_name}-vof-app-server", "vof-app-server"]

  network_interface {
	subnetwork = "${google_compute_subnetwork.vof-private-subnetwork.name}"
	access_config {}
  }

  disk {
    source_image = "${var.vof_disk_image}"
    auto_delete = true
    boot = true
    disk_type = "${var.vof_disk_type}"
    disk_size_gb = "${var.vof_disk_size}"
  }

  metadata {
    databaseUser = "${var.db_username}"
    databasePassword = "${random_id.vof-db-user-password.b64}"
    databaseHost = "${google_sql_database_instance.vof-database-instance.ip_address.0.ip_address}"
    databasePort = "5432"
    databaseName = "${var.env_name}-vof-database"
    startup-script = "/home/vof/start_vof.sh"
    serial-port-enable = 1
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_autoscaler" "vof-app-autoscaler" {
  name = "${var.env_name}-vof-app-autoscaler"
  zone = "${var.zone}"
  target = "${google_compute_instance_group_manager.vof-app-server-group-manager.self_link}"
  autoscaling_policy = {
    max_replicas = "${var.max_instances}"
    min_replicas = "${var.min_instances}"
    cooldown_period = 60
    cpu_utilization {
      target = 0.7
    }
  }
}

resource "google_compute_http_health_check" "vof-app-healthcheck"{
  name = "${var.env_name}-vof-app-healthcheck"
  port = 8080
  request_path = "${var.request_path}"
  check_interval_sec = "${var.check_interval_sec}"
  timeout_sec = "${var.timeout_sec}"
  unhealthy_threshold = "${var.unhealthy_threshold}"
  healthy_threshold = "${var.healthy_threshold}"
}
