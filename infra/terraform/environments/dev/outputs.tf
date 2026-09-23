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