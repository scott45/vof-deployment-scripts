output "db-username" {
  value = "${random_id.login-microservice-db-user.b64}"
}

output "db-password" {
  value = "${random_id.login-microservice-db-user-password.b64}"
}

output "db-host" {
  value = "${google_sql_database_instance.login-microservice-database-instance.ip_address.0.ip_address}"
}
