output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the development VPC."
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the development public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the development private subnets."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs of the development NAT Gateways."
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Public IP addresses assigned to the NAT Gateways."
  value       = module.vpc.nat_gateway_public_ips
}

output "s3_gateway_endpoint_id" {
  description = "ID of the development S3 Gateway Endpoint."
  value       = module.vpc.s3_gateway_endpoint_id
}

output "ecr_repository_names" {
  description = "ECR repository names keyed by service."
  value       = module.ecr.repository_names
}

output "ecr_repository_arns" {
  description = "ECR repository ARNs keyed by service."
  value       = module.ecr.repository_arns
}

output "ecr_repository_urls" {
  description = "ECR repository URLs keyed by service."
  value       = module.ecr.repository_urls
}

output "eks_cluster_role_name" {
  description = "Name of the development EKS cluster IAM role."
  value       = module.iam.eks_cluster_role_name
}

output "eks_cluster_role_arn" {
  description = "ARN of the development EKS cluster IAM role."
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_role_name" {
  description = "Name of the development EKS worker-node IAM role."
  value       = module.iam.eks_node_role_name
}

output "eks_node_role_arn" {
  description = "ARN of the development EKS worker-node IAM role."
  value       = module.iam.eks_node_role_arn
}

output "eks_node_instance_profile_name" {
  description = "Name of the development EKS worker-node instance profile."
  value       = module.iam.eks_node_instance_profile_name
}

output "eks_cluster_name" {
  description = "Name of the development EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_version" {
  description = "Kubernetes version running on the development EKS cluster."
  value       = module.eks.cluster_version
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint for the development EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Name of the development EKS managed node group."
  value       = module.eks.node_group_name
}

output "eks_node_group_status" {
  description = "Status of the development EKS managed node group."
  value       = module.eks.node_group_status
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL for the development EKS cluster."
  value       = module.eks.oidc_issuer_url
}

output "eks_oidc_provider_arn" {
  description = "ARN of the development EKS IAM OIDC provider."
  value       = module.eks.oidc_provider_arn
}

output "eks_kms_key_arn" {
  description = "ARN of the KMS key protecting Kubernetes secrets."
  value       = module.eks.kms_key_arn
}

output "eks_cloudwatch_log_group_name" {
  description = "CloudWatch log group containing EKS control-plane logs."
  value       = module.eks.cloudwatch_log_group_name
}