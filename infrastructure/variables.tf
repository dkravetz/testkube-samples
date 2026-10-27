# app and env are set on each workspace by the platform.

variable "app" {
  description = "App name; prefixes every resource."
  type        = string
}

variable "env" {
  description = "Environment: dev or prd."
  type        = string

  validation {
    condition     = contains(["dev", "prd"], var.env)
    error_message = "env must be dev or prd."
  }
}

variable "vpc_name" {
  description = "Name tag of the platform's VPC the database goes in."
  type        = string
  default     = "testkube-poc"
}
