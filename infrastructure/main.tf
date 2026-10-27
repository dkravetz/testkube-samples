# The API's Postgres database, and its credentials in Secrets Manager under
# apps/<app>/<env>/db/main, where the platform's External Secrets Operator picks them up.
#
# Sizing comes from app.yaml: `infrastructure.vars`, with `envs.<env>.infrastructure.vars`
# merged over it. Terrakube clones the whole repo at the workspace's ref, so this is always the
# app.yaml of the same commit as this code.

locals {
  name = "${var.app}-${var.env}"

  app_yaml = yamldecode(file("${path.module}/../app.yaml"))
  # Both blocks are optional; an env must exist in app.yaml's envs.
  infrastructure_vars = merge(
    try(local.app_yaml.infrastructure.vars, {}),
    try(local.app_yaml.envs[var.env].infrastructure.vars, {}),
  )
  # What app.yaml may set; anything else fails the plan (data.tf).
  known_vars = ["db_instance_class", "db_allocated_storage"]
}

module "database" {
  source = "./modules/postgres"

  name           = local.name
  vpc_id         = data.aws_vpc.platform.id
  vpc_cidr_block = data.aws_vpc.platform.cidr_block
  subnet_ids     = data.aws_subnets.private.ids

  db_name     = "api"
  username    = "api"
  secret_name = "apps/${var.app}/${var.env}/db/main"

  # Unset in app.yaml: the module's defaults.
  instance_class    = lookup(local.infrastructure_vars, "db_instance_class", null)
  allocated_storage = lookup(local.infrastructure_vars, "db_allocated_storage", null)
}
