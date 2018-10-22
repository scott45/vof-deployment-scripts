resource "google_compute_backend_service" "web" {
  # vof-production-loadbalancer
  name        = "${format("%s-%s-loadbalancer", var.project_name, var.environment)}"
  description = "${format(" %s loadbalancer", var.project_name)}"
  port_name   = "customhttps"
  protocol    = "HTTPS"
  timeout_sec = 120
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.manager.instance_group}"
  }

  session_affinity = "GENERATED_COOKIE"

  health_checks = ["${google_compute_https_health_check.healthcheck.self_link}"]
}

resource "google_compute_instance_group_manager" "manager" {
  # vof-production-instance-group-manager
  name = "${format("%s-%s-instance-group-manager", var.project_name, var.environment)}"

  # vof-production-app-instance
  base_instance_name = "${format("%s-%s-app-instance", var.project_name, var.environment)}"
  instance_template  = "${google_compute_instance_template.template.self_link}"
  zone               = "${var.zone}"
  update_strategy    = "NONE"

  named_port {
    name = "customhttps"
    port = 8080
  }
}

resource "google_compute_instance_template" "template" {
  # vof-production-template-mknnkjnkn
  name_prefix          = "${format("%s-%s-template-", var.project_name, var.environment)}"
  machine_type         = "${var.machine_type}"
  region               = "${var.region}"
  description          = "Base template to create ${var.project_name} instances"
  instance_description = "Instance created from base template"

  depends_on = [
    "google_sql_database_instance.instance",
    "random_id.database_password",
  ]

  tags = [
    # vof-production-app-server
    "${format("%s-%s-app-server", var.project_name, var.environment)}",

    "${var.project_name}-app-server",
  ]

  network_interface {
    subnetwork    = "${module.network.private_network_name}"
    access_config = {}
  }

  disk {
    source_image = "${var.disk_image}"
    auto_delete  = true
    boot         = true
    disk_type    = "${var.disk_type}"
    disk_size_gb = "${var.disk_size}"
  }

  metadata {
    bugsnagKey                       = "${var.bugsnag_key}"
    cableURL                         = "${var.cable_url}"
    databasePort                     = "5432"
    databaseName                     = "${format("%s-%s", var.project_name, var.environment )}"
    redisIp                          = "${var.redis_domain}:6379"
    railsEnv                         = "${var.environment}"
    bucketName                       = "${var.bucket}"
    slackChannel                     = "${var.slack_channel}"
    slackWebhook                     = "${var.slack_webhook_url}"
    startup-script                   = "/home/vof/start_vof.sh"
    serial-port-enable               = 1
    userMicroserviceApiUrl           = "${var.user_microservice_api_url}"
    userMicroserviceApiToken         = "${var.user_microservice_api_token}"
    google_storage_access_key_id     = "${var.google_storage_access_key_id}"
    google_storage_secret_access_key = "${var.google_storage_secret_access_key}"
    dbBackupNotificationToken        = "${var.db_backup_notification_token}"

    databaseInstanceName = "${var.environment == "production"
    ? format("%s-%s-database-instance-%s", var.project_name, var.environment,
    "${replace(lower(random_id.database_instance_name.b64), "_", "-")}") :
    var.shared_database_instance_name }"

    databaseUser = "${random_id.database_username.b64}"

    databasePassword = "${random_id.database_password.b64}"

    databaseHost = "${google_sql_database_instance.instance.ip_address.0.ip_address}"
  }

  lifecycle {
    create_before_destroy = true
  }

  # the email is the service account email whose service keys have all the roles suffiecient enough
  # for the project to interract with all the APIs it does interract with.
  # the scopes are those that we need for logging and monitoring, they are a must for logging to
  # be carried out.
  # the whole service account argument is required for identity and authentication reasons, if it is
  # not included here, the default service account is used instead.
  service_account {
    email = "${var.service_account_email}"

    scopes = [
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.read",
      "https://www.googleapis.com/auth/logging.write",
    ]
  }
}

resource "google_compute_autoscaler" "autoscaler" {
  # vof-production-app-autoscaler
  name   = "${format("%s-%s-app-autoscaler", var.project_name, var.environment)}"
  zone   = "${var.zone}"
  target = "${google_compute_instance_group_manager.manager.self_link}"

  autoscaling_policy = {
    max_replicas    = "${var.max_instances}"
    min_replicas    = "${var.min_instances}"
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}

resource "google_compute_https_health_check" "healthcheck" {
  # vof-production-app-healthcheck
  name                = "${format("%s-%s-app-healthcheck", var.project_name, var.environment)}"
  port                = "${var.health_checks_port}"
  request_path        = "${var.request_path}"
  check_interval_sec  = "${var.check_interval_sec}"
  timeout_sec         = "${var.timeout_sec}"
  unhealthy_threshold = "${var.unhealthy_threshold}"
  healthy_threshold   = "${var.healthy_threshold}"
}

resource "google_compute_global_address" "global_static_ip" {
  name = "${format("%s-%s-global-static-ip", var.project_name, var.environment)}"
}
