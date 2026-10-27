variable "name" {
  description = "Name of the instance, its security group and subnet group."
  type        = string
}

variable "vpc_id" {
  description = "VPC the database goes in."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR allowed to reach Postgres."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets of the database (two AZs or more)."
  type        = list(string)
}

variable "db_name" {
  description = "Database created on the instance."
  type        = string
}

variable "username" {
  description = "Master user."
  type        = string
}

variable "secret_name" {
  description = "Secrets Manager secret for host, port, dbname, username and password."
  type        = string
}

# Sizing: app.yaml can set these per env (infrastructure.vars); null means the default.

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
  nullable    = false
}

variable "allocated_storage" {
  description = "Storage in GiB."
  type        = number
  default     = 20
  nullable    = false
}
