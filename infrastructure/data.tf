data "aws_vpc" "platform" {
  tags = {
    Name = var.vpc_name
  }

  # Checked here, the first thing the plan reads: a typo in app.yaml fails loudly.
  lifecycle {
    precondition {
      condition     = length(setsubtract(keys(local.infrastructure_vars), local.known_vars)) == 0
      error_message = "Unknown keys in app.yaml infrastructure.vars (${var.env}): ${join(", ", setsubtract(keys(local.infrastructure_vars), local.known_vars))}. Known: ${join(", ", local.known_vars)}."
    }
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.platform.id]
  }

  tags = {
    Name = "${var.vpc_name}-private-*"
  }
}
