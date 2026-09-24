output "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role."
  value       = aws_iam_role.eks_cluster.name
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = aws_iam_role.eks_cluster.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]
}

output "eks_node_role_name" {
  description = "Name of the EKS worker-node IAM role."
  value       = aws_iam_role.eks_node.name
}

output "eks_node_role_arn" {
  description = "ARN of the EKS worker-node IAM role."
  value       = aws_iam_role.eks_node.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.ecr_pull_only,
    aws_iam_role_policy_attachment.vpc_cni
  ]
}

output "eks_node_instance_profile_name" {
  description = "Name of the EKS worker-node instance profile."
  value       = aws_iam_instance_profile.eks_node.name
}

output "eks_node_instance_profile_arn" {
  description = "ARN of the EKS worker-node instance profile."
  value       = aws_iam_instance_profile.eks_node.arn
}