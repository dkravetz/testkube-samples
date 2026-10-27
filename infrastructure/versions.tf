# Run by the platform's Terrakube workspaces testkube-samples-dev and testkube-samples-prd.
# Terrakube adds the state backend and the AWS credentials, region and endpoint (environment).
terraform {
  required_version = "~> 1.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.70"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      app = var.app
      env = var.env
    }
  }
}
