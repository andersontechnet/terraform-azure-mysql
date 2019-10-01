output "administrator_login" {
  value       = "${random_string.mysql_login.result}"
  description = "The user for logging in to the database."
  sensitive   = true
}

output "administrator_login_password" {
  value       = "${random_string.mysql_pwd.result}"
  description = "The password for logging in to the database."
  sensitive   = true
}
