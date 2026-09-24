variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string

  validation {
    condition = (
      length(var.cluster_name) >= 3 &&
      length(var.cluster_name) <= 100 &&
      can(regex("^[0-9A-Za-z][0-9A-Za-z_-]*$", var.cluster_name))
    )
    error_message = "cluster_name must be 3-100 valid EKS name characters."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes minor version used by the EKS cluster."
  type        = string
  default     = "1.36"

  validation {
    condition     = can(regex("^1\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must use a minor-version format such as 1.36."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster and managed nodes."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnet IDs must be supplied."
  }
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS control plane."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:role/", var.cluster_role_arn))
    error_message = "cluster_role_arn must be a valid IAM role ARN."
  }
}

variable "node_role_arn" {
  description = "ARN of the IAM role used by the managed worker nodes."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:role/", var.node_role_arn))
    error_message = "node_role_arn must be a valid IAM role ARN."
  }
}

variable "endpoint_private_access" {
  description = "Whether the Kubernetes API endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Kubernetes API endpoint is reachable from approved public networks."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks permitted to reach the public Kubernetes API endpoint."
  type        = list(string)

  validation {
    condition = (
      !var.endpoint_public_access ||
      (
        length(var.public_access_cidrs) > 0 &&
        !contains(var.public_access_cidrs, "0.0.0.0/0")
      )
    )
    error_message = "Public endpoint access requires at least one restricted CIDR; 0.0.0.0/0 is prohibited."
  }
}

variable "enabled_cluster_log_types" {
  description = "EKS control-plane log types sent to CloudWatch."
  type        = list(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types :
      contains(
        [
          "api",
          "audit",
          "authenticator",
          "controllerManager",
          "scheduler"
        ],
        log_type
      )
    ])
    error_message = "One or more unsupported EKS control-plane log types were supplied."
  }
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days EKS control-plane logs are retained."
  type        = number
  default     = 365

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365],
      var.cloudwatch_log_retention_days
    )
    error_message = "cloudwatch_log_retention_days must be a supported CloudWatch retention value."
  }
}

variable "node_group_name" {
  description = "Name assigned to the EKS managed node group."
  type        = string
  default     = "general"
}

variable "node_instance_types" {
  description = "EC2 instance types available to the managed node group."
  type        = list(string)
  default     = ["t3.small"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "At least one node instance type must be supplied."
  }
}

variable "node_capacity_type" {
  description = "Capacity type used by the managed node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.node_min_size >= 1
    error_message = "node_min_size must be at least one."
  }
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_size >= var.node_min_size
    error_message = "node_desired_size must be greater than or equal to node_min_size."
  }
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3

  validation {
    condition     = var.node_max_size >= var.node_desired_size
    error_message = "node_max_size must be greater than or equal to node_desired_size."
  }
}

variable "node_disk_size" {
  description = "Worker-node root EBS volume size in GiB."
  type        = number
  default     = 30

  validation {
    condition     = var.node_disk_size >= 20
    error_message = "node_disk_size must be at least 20 GiB."
  }
}

variable "node_labels" {
  description = "Kubernetes labels assigned to managed nodes."
  type        = map(string)

  default = {
    workload = "general"
  }
}

variable "tags" {
  description = "Additional tags applied to EKS resources."
  type        = map(string)
  default     = {}
}