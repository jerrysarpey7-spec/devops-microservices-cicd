variable "project_name" {
  description = "Project name used in IAM resource names and tags."
  type        = string

  validation {
    condition = (
      length(trimspace(var.project_name)) >= 3 &&
      length(var.project_name) <= 30 &&
      can(regex("^[a-z0-9-]+$", var.project_name))
    )
    error_message = "project_name must contain 3-30 lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment such as dev, staging, or production."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be dev, staging, or production."
  }
}

variable "attach_vpc_cni_policy" {
  description = "Whether to attach the VPC CNI policy to the node role during initial cluster bootstrap."
  type        = bool
  default     = true
}

variable "permissions_boundary_arn" {
  description = "Optional permissions-boundary ARN applied to the IAM roles."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.permissions_boundary_arn == null ||
      can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:policy/", var.permissions_boundary_arn))
    )
    error_message = "permissions_boundary_arn must be null or a valid IAM policy ARN."
  }
}

variable "tags" {
  description = "Additional tags applied to IAM resources."
  type        = map(string)
  default     = {}
}