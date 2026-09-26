variable "project_name" {
  description = "Project name used in IAM resource names and tags."
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name cannot be empty."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be dev, staging, or production."
  }
}

variable "github_owner" {
  description = "GitHub organization or account that owns the repository."
  type        = string

  validation {
    condition     = length(trimspace(var.github_owner)) > 0
    error_message = "github_owner cannot be empty."
  }
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the CI/CD role."
  type        = string

  validation {
    condition     = length(trimspace(var.github_repository)) > 0
    error_message = "github_repository cannot be empty."
  }
}

variable "allowed_branch" {
  description = "Git branch allowed to assume the deployment role."
  type        = string
  default     = "develop"
}

variable "github_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN. Leave null to create one."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.github_oidc_provider_arn == null ||
      can(regex(
        "^arn:aws[a-z-]*:iam::[0-9]{12}:oidc-provider/token\\.actions\\.githubusercontent\\.com$",
        var.github_oidc_provider_arn
      ))
    )
    error_message = "github_oidc_provider_arn must be null or a valid GitHub Actions OIDC provider ARN."
  }
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs that GitHub Actions may push images to."
  type        = set(string)

  validation {
    condition = (
      length(var.ecr_repository_arns) > 0 &&
      alltrue([
        for arn in var.ecr_repository_arns :
        can(regex("^arn:aws[a-z-]*:ecr:", arn))
      ])
    )
    error_message = "At least one valid ECR repository ARN must be supplied."
  }
}

variable "eks_cluster_name" {
  description = "EKS cluster that receives Helm deployments."
  type        = string

  validation {
    condition     = length(trimspace(var.eks_cluster_name)) > 0
    error_message = "eks_cluster_name cannot be empty."
  }
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace GitHub Actions may administer."
  type        = string
  default     = "devops-microservices"

  validation {
    condition = can(regex(
      "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$",
      var.kubernetes_namespace
    ))
    error_message = "kubernetes_namespace must be a valid Kubernetes namespace."
  }
}

variable "permissions_boundary_arn" {
  description = "Optional IAM permissions boundary attached to the deployment role."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}