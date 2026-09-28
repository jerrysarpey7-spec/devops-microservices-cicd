output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded Kubernetes API certificate authority data."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version running on the EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_security_group_id" {
  description = "Security group created by EKS for the cluster."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "Name of the EKS managed node group."
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_status" {
  description = "Status of the EKS managed node group."
  value       = aws_eks_node_group.this.status
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL associated with the EKS cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider."
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for Kubernetes secret encryption."
  value       = aws_kms_key.eks.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group containing EKS control-plane logs."
  value       = aws_cloudwatch_log_group.eks.name
}