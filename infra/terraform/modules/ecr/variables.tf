variable "project_name" {
  description = "Project name used in repository names and tags."
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "The project_name value cannot be empty."
  }
}

variable "environment" {
  description = "Deployment environment such as dev, staging, or production."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "The environment must be dev, staging, or production."
  }
}

variable "repository_names" {
  description = "Names of the application repositories to create."
  type        = set(string)

  validation {
    condition     = length(var.repository_names) > 0
    error_message = "At least one ECR repository name must be provided."
  }

  validation {
    condition = alltrue([
      for name in var.repository_names :
      can(regex("^[a-z0-9]+([._-][a-z0-9]+)*$", name))
    ])
    error_message = "Repository names must use lowercase letters, numbers, periods, underscores, or hyphens."
  }
}

variable "image_tag_mutability" {
  description = "Whether image tags are mutable or immutable."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.image_tag_mutability
    )
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Whether ECR scans images when they are pushed."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "ECR encryption type: AES256 or KMS."
  type        = string
  default     = "KMS"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "Optional customer-managed KMS key ARN. When null, ECR uses the AWS-managed ECR KMS key."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.kms_key_arn == null ||
      can(regex("^arn:aws[a-z-]*:kms:", var.kms_key_arn))
    )
    error_message = "kms_key_arn must be null or a valid AWS KMS key ARN."
  }
}

variable "untagged_image_retention_days" {
  description = "Number of days to retain untagged images."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_retention_days >= 1
    error_message = "Untagged images must be retained for at least one day."
  }
}

variable "maximum_image_count" {
  description = "Maximum number of images retained in each repository."
  type        = number
  default     = 30

  validation {
    condition     = var.maximum_image_count >= 1
    error_message = "maximum_image_count must be at least one."
  }
}

variable "tags" {
  description = "Additional tags applied to ECR repositories."
  type        = map(string)
  default     = {}
}