# The API's Postgres database, and its credentials in Secrets Manager under
# apps/<app>/<env>/db/main, where the platform's External Secrets Operator picks them up.

locals {
  name        = "${var.app}-${var.env}"
  db_name     = "api"
  db_username = "api"
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name        = "${local.name}-db"
  description = "${local.name} Postgres, reachable from the VPC"
  vpc_id      = data.aws_vpc.platform.id

  ingress_rules = {
    postgres = {
      from_port = 5432
      to_port   = 5432
      cidr_ipv4 = data.aws_vpc.platform.cidr_block
    }
  }
}

resource "random_password" "db" {
  length  = 32
  special = false
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.2"

  identifier = local.name

  engine               = "postgres"
  engine_version       = "18"
  family               = "postgres18"
  major_engine_version = "18"
  instance_class       = "db.t4g.micro"
  allocated_storage    = 20

  db_name  = local.db_name
  username = local.db_username
  port     = 5432

  # Our own password, so the secret below can hold it; never in the plan.
  manage_master_user_password = false
  password_wo                 = random_password.db.result
  password_wo_version         = 1

  create_db_subnet_group = true
  subnet_ids             = data.aws_subnets.private.ids
  vpc_security_group_ids = [module.security_group.id]

  create_db_option_group    = false
  create_db_parameter_group = false

  skip_final_snapshot = true
  deletion_protection = false
}

module "db_secret" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 2.2"

  name        = "apps/${var.app}/${var.env}/db/main"
  description = "${local.name} database credentials"
  # Deleted at once, so a destroy and apply can reuse the name.
  recovery_window_in_days = 0

  secret_string = jsonencode({
    host     = module.db.db_instance_address
    port     = module.db.db_instance_port
    dbname   = local.db_name
    username = local.db_username
    password = random_password.db.result
  })
}
