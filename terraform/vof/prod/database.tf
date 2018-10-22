resource "random_id" "database_instance_name" {
  byte_length = 8
}

resource "random_id" "database_username" {
  byte_length = 8
}

resource "random_id" "database_password" {
  byte_length = 16
}

resource "google_sql_database_instance" "instance" {
  region           = "${var.region}"
  database_version = "POSTGRES_9_6"

  # vof-production-database-instance-hjErad664")
  name = "${format(
    "%s-%s-database-instance-%s",
    var.project_name, var.environment,
    "${replace(lower(random_id.database_instance_name.b64), "_", "-")}")}"

  project = "${var.google_project_id}"
  count   = 1

  settings {
    tier              = "${var.db_instance_tier}"
    availability_type = "REGIONAL"
    disk_autoresize   = true

    ip_configuration = {
      ipv4_enabled = true

      authorized_networks = [{
        name  = "all"
        value = "0.0.0.0/0"
      }]
    }

    backup_configuration {
      binary_log_enabled = false
      enabled            = true
      start_time         = "${var.db_backup_start_time}"
    }
  }
}

resource "google_sql_database" "database" {
  # vof-production
  name      = "${format("%s-%s", var.project_name, var.environment )}"
  charset   = "UTF8"
  collation = "en_US.UTF8"

  instance = "${google_sql_database_instance.instance.name}"
}

resource "google_sql_user" "database-user" {
  name     = "${random_id.database_username.b64}"
  password = "${random_id.database_password.b64}"
  host     = ""

  instance = "${google_sql_database_instance.instance.name}"
}
