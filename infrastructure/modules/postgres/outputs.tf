output "secret_name" {
  description = "Secrets Manager secret with the database's host, port, dbname, username and password."
  value       = module.db_secret.secret_name
}

output "instance_class" {
  description = "RDS instance class in use."
  value       = var.instance_class
}

output "allocated_storage" {
  description = "Storage in GiB."
  value       = var.allocated_storage
}
