data "aws_vpc" "platform" {
  tags = {
    Name = var.vpc_name
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
