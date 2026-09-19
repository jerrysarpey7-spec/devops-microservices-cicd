variable "aws_region" {
  description = "AWS region containing the Terraform state bucket."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used to generate globally unique resource names."
  type        = string
  default     = "devops-microservices"

  validation {
    condition = can(
      regex("^[a-z0-9-]+$", var.project_name)
    )
    error_message = "Project name must contain lowercase letters, numbers, and hyphens only."
  }
}

variable "tags" {
  description = "Additional tags applied to bootstrap resources."
  type        = map(string)
  default     = {}
}