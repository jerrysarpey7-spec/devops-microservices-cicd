variable "project_name" {
  description = "Name of the project used in resource names and tags."
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
    condition = contains(
      ["dev", "staging", "production"],
      var.environment
    )
    error_message = "The environment must be dev, staging, or production."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the public and private subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones must be provided."
  }

  validation {
    condition     = length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "Each Availability Zone must be unique."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to the public subnets."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))
    ])
    error_message = "Every public subnet value must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "Provide one public subnet CIDR for each Availability Zone."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to the private subnets."
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))
    ])
    error_message = "Every private subnet value must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "Provide one private subnet CIDR for each Availability Zone."
  }
}

variable "enable_nat_gateway" {
  description = "Whether NAT Gateways should be created for private subnet internet access."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether all private subnets should share one NAT Gateway."
  type        = bool
  default     = true
}

variable "enable_s3_gateway_endpoint" {
  description = "Whether to create an S3 Gateway Endpoint for the private route tables."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether the VPC should assign DNS hostnames."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether DNS resolution is supported inside the VPC."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to the VPC resources."
  type        = map(string)
  default     = {}
}