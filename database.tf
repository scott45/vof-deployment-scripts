resource "random_id" "db-name" {
  byte_length = 8
}

resource "random_id" "vof-db-user-password" {
  byte_length = 16
}

resource "google_sql_database_instance" "vof-database-instance" {
  region = "${var.region}"
  database_version = "POSTGRES_9_6"
  name = "${var.env_name}-vof-database-instance-${replace(lower(random_id.db-name.b64), "_", "-")}"
  project = "${var.project_id}"

  settings {
    tier = "${var.db_instance_tier}"
    ip_configuration = {
      ipv4_enabled = true

      authorized_networks = [{
        name = "all"
        value = "0.0.0.0/0"
      }]
    }
  }
}

resource "google_sql_database" "vof-database" {
  name = "${var.env_name}-vof-database"
  instance = "${google_sql_database_instance.vof-database-instance.name}"
  charset = "UTF8"
  collation = "en_US.UTF8"
}

resource "google_sql_user" "vof-database-user" {
  name = "${var.db_username}"
  password = "${random_id.vof-db-user-password.b64}"
  instance = "${google_sql_database_instance.vof-database-instance.name}"
  host = "${var.vof_host}"
}

output "vof_db_user_name" {
  value = "${var.db_username}"
}

output "vof_db_user_password" {
  value = "${random_id.vof-db-user-password.b64}"
}

output "vof_db_instance_ip" {
  value = "${google_sql_database_instance.vof-database-instance.ip_address.0.ip_address}"
}
