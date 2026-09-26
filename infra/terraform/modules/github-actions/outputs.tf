output "role_name" {
  description = "Name of the GitHub Actions deployment role."
  value       = aws_iam_role.github_actions.name
}

output "role_arn" {
  description = "ARN of the GitHub Actions deployment role."
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = local.github_oidc_provider_arn
}

output "allowed_subject" {
  description = "GitHub OIDC subject allowed to assume the deployment role."
  value       = local.github_subject
}

output "eks_access_entry_arn" {
  description = "ARN of the EKS access entry created for GitHub Actions."
  value       = aws_eks_access_entry.github_actions.access_entry_arn
}