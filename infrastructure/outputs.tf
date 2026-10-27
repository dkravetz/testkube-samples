output "db_secret_name" {
  description = "Secrets Manager secret with the database's host, port, dbname, username and password."
  value       = module.database.secret_name
}

output "db_instance_class" {
  description = "RDS instance class this env runs (app.yaml or the module's default)."
  value       = module.database.instance_class
}

output "db_allocated_storage" {
  description = "Database storage in GiB this env runs (app.yaml or the module's default)."
  value       = module.database.allocated_storage
}
