resource "random_id" "database_instance_name" {
  byte_length = 8
}

resource "random_id" "database_username" {
  byte_length = 8
}

resource "random_id" "database_password" {
  byte_length = 16
}

resource "google_sql_database" "database" {
  # vof-production
  name      = "${format("%s-%s", var.project_name, var.environment )}"
  charset   = "UTF8"
  collation = "en_US.UTF8"

  instance = "${var.shared_database_instance_name}"
}

resource "google_sql_user" "database-user" {
  name     = "${random_id.database_username.b64}"
  password = "${random_id.database_password.b64}"
  host     = ""

  instance = "${var.shared_database_instance_name}"
}
