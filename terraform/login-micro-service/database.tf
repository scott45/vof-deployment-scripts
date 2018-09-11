resource "random_id" "login-microservice-db-name" {
  byte_length = 8
}

resource "random_id" "login-microservice-db-user" {
  byte_length = 8
}

resource "random_id" "login-microservice-db-user-password" {
  byte_length = 16
}

resource "google_sql_database_instance" "login-microservice-database-instance" {
  region = "${var.login_microservice_region}"
  database_version = "POSTGRES_9_6"
  name = "${var.login_microservice_env_name}-login-microservice-database-instance-${replace(lower(random_id.login-microservice-db-name.b64), "_", "-")}"
  project = "${var.login_microservice_project_id}"

  settings {
    tier = "${var.login_microservice_db_instance_tier}"
    availability_type = "REGIONAL"
    disk_autoresize = true
    ip_configuration = {
      ipv4_enabled = true

      authorized_networks = [{
        name = "all"
        value = "0.0.0.0/0"
      }]
    }

    backup_configuration {
      binary_log_enabled = true
      enabled = true
      start_time = "${var.login_microservice_db_backup_start_time}"
    }
  }
}

resource "google_sql_database" "login-microservice-database" {
  name = "${var.login_microservice_env_name}-login-microservice-database"
  instance = "${google_sql_database_instance.login-microservice-database-instance.name}"
  charset = "UTF8"
  collation = "en_US.UTF8"
}

resource "google_sql_user" "login-microservice-database-user" {
  name = "${random_id.login-microservice-db-user.b64}"
  password = "${random_id.login-microservice-db-user-password.b64}"
  instance = "${google_sql_database_instance.login-microservice-database-instance.name}"
  host = ""
}
