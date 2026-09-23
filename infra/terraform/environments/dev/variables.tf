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