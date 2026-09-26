variable "aws_region" {
  description = "AWS Region used for the development environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for naming and tagging resources."
  type        = string
  default     = "devops-microservices"
}

variable "environment" {
  description = "Name of the deployment environment."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the development VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the development environment."
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to the public subnets."
  type        = list(string)

  default = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to the private subnets."
  type        = list(string)

  default = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]
}

variable "enable_nat_gateway" {
  description = "Whether the development VPC creates NAT Gateway connectivity."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether the private subnets share one NAT Gateway."
  type        = bool
  default     = true
}

variable "enable_s3_gateway_endpoint" {
  description = "Whether the development VPC creates an S3 Gateway Endpoint."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to development resources."
  type        = map(string)

  default = {
    CostCenter = "portfolio"
    Owner      = "platform-engineering"
  }
}

variable "service_names" {
  description = "Microservice names requiring private ECR repositories."
  type        = set(string)

  default = [
    "user-service",
    "order-service",
    "payment-service",
    "notification-service"
  ]
}

variable "ecr_image_tag_mutability" {
  description = "Image-tag mutability used by development ECR repositories."
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Whether development images are scanned when pushed."
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "Encryption type used by the development ECR repositories."
  type        = string
  default     = "KMS"

  validation {
    condition = contains(
      ["AES256", "KMS"],
      var.ecr_encryption_type
    )
    error_message = "ecr_encryption_type must be AES256 or KMS."
  }
}

variable "ecr_untagged_image_retention_days" {
  description = "Days before untagged development images expire."
  type        = number
  default     = 7
}

variable "ecr_maximum_image_count" {
  description = "Maximum number of images retained in each development repository."
  type        = number
  default     = 30
}

variable "iam_attach_vpc_cni_policy" {
  description = "Whether the VPC CNI policy is temporarily attached to the EKS node role."
  type        = bool
  default     = true
}

variable "iam_permissions_boundary_arn" {
  description = "Optional permissions-boundary ARN applied to development IAM roles."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.iam_permissions_boundary_arn == null ||
      can(regex(
        "^arn:aws[a-z-]*:iam::[0-9]{12}:policy/",
        var.iam_permissions_boundary_arn
      ))
    )
    error_message = "iam_permissions_boundary_arn must be null or a valid IAM policy ARN."
  }
}

variable "eks_cluster_name" {
  description = "Name of the development EKS cluster."
  type        = string
  default     = "devops-microservices-dev"
}

variable "eks_kubernetes_version" {
  description = "Kubernetes version used by the development EKS cluster."
  type        = string
  default     = "1.36"
}

variable "eks_endpoint_private_access" {
  description = "Whether the EKS API is reachable privately from the VPC."
  type        = bool
  default     = true
}

variable "eks_endpoint_public_access" {
  description = "Whether the EKS API is reachable from approved public networks."
  type        = bool
  default     = true
}

variable "eks_public_access_cidrs" {
  description = "Restricted public CIDRs permitted to access the EKS API."
  type        = list(string)
  default     = ["192.0.2.0/24"]

  validation {
    condition = (
      length(var.eks_public_access_cidrs) > 0 &&
      !contains(var.eks_public_access_cidrs, "0.0.0.0/0")
    )
    error_message = "eks_public_access_cidrs must contain restricted CIDRs and cannot include 0.0.0.0/0."
  }
}

variable "eks_cloudwatch_log_retention_days" {
  description = "Retention period for EKS control-plane logs."
  type        = number
  default     = 365
}

variable "eks_node_instance_types" {
  description = "EC2 instance types used by the development node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_node_capacity_type" {
  description = "Capacity type used by the development node group."
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_node_min_size" {
  description = "Minimum number of development worker nodes."
  type        = number
  default     = 2
}

variable "eks_node_desired_size" {
  description = "Desired number of development worker nodes."
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of development worker nodes."
  type        = number
  default     = 3
}

variable "eks_node_disk_size" {
  description = "Root EBS volume size for development worker nodes."
  type        = number
  default     = 30
}

variable "github_owner" {
  description = "GitHub account that owns the project repository."
  type        = string
  default     = "jerrysarpey7-spec"
}

variable "github_repository" {
  description = "GitHub repository used by the CI/CD workflow."
  type        = string
  default     = "devops-microservices-cicd"
}

variable "github_deployment_branch" {
  description = "Git branch allowed to assume the AWS deployment role."
  type        = string
  default     = "develop"
}

variable "github_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN, or null to create one."
  type        = string
  default     = null
  nullable    = true
}

variable "kubernetes_application_namespace" {
  description = "Kubernetes namespace administered by the CI/CD workflow."
  type        = string
  default     = "devops-microservices"
}