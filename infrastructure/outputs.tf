output "db_secret_name" {
  description = "Secrets Manager secret with the database's host, port, dbname, username and password."
  value       = module.db_secret.secret_name
}
