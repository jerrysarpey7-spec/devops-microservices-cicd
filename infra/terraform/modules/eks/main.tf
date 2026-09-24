
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  cloudwatch_log_group_name = "/aws/eks/${var.cluster_name}/cluster"

  cloudwatch_log_group_arn = join(
    "",
    [
      "arn:",
      data.aws_partition.current.partition,
      ":logs:",
      data.aws_region.current.region,
      ":",
      data.aws_caller_identity.current.account_id,
      ":log-group:",
      local.cloudwatch_log_group_name
    ]
  )

  common_tags = merge(
    {
      Project   = var.cluster_name
      ManagedBy = "Terraform"
      Component = "eks"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "eks_kms" {
  #checkov:skip=CKV_AWS_111:KMS administration is restricted to the owning AWS account, while CloudWatch usage is constrained by service principal and encryption context.
  #checkov:skip=CKV_AWS_356:KMS key policies require Resource "*" because the policy is attached directly to and governs the current key.
  #checkov:skip=CKV_AWS_109:The account-administration statement is restricted to the owning AWS account and prevents KMS key lockout.
  statement {
    sid = "EnableAccountKeyAdministration"

    actions = [
      "kms:*"
    ]

    resources = ["*"]

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }

  statement {
    sid = "AllowCloudWatchLogsEncryption"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]

    principals {
      type = "Service"

      identifiers = [
        "logs.${data.aws_region.current.region}.${data.aws_partition.current.dns_suffix}"
      ]
    }

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        local.cloudwatch_log_group_arn
      ]
    }
  }
}

resource "aws_kms_key" "eks" {
  description             = "KMS key for ${var.cluster_name} Kubernetes secrets and control-plane logs."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.eks_kms.json

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-secrets"
    }
  )
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks.key_id
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = aws_kms_key.eks.arn

  tags = merge(
    local.common_tags,
    {
      Name = local.cloudwatch_log_group_name
    }
  )
}

resource "aws_eks_cluster" "this" {
  #checkov:skip=CKV_AWS_39:The development API endpoint supports local administration and is restricted to an operator-specific /32 CIDR.
  #checkov:skip=CKV_AWS_339:Amazon EKS officially supports Kubernetes 1.36, but the current Checkov policy version has not yet added it to its accepted-version list.
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = var.enabled_cluster_log_types

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }

    resources = ["secrets"]
  }

  depends_on = [
    aws_cloudwatch_log_group.eks
  ]

  tags = merge(
    local.common_tags,
    {
      Name = var.cluster_name
    }
  )
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = local.common_tags
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  version         = var.kubernetes_version

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = var.node_capacity_type
  disk_size      = var.node_disk_size
  instance_types = var.node_instance_types

  scaling_config {
    min_size     = var.node_min_size
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = var.node_labels

  depends_on = [
    aws_eks_addon.vpc_cni
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-${var.node_group_name}"
    }
  )
}

resource "aws_eks_addon" "after_compute" {
  for_each = toset([
    "coredns",
    "kube-proxy",
    "eks-pod-identity-agent"
  ])

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.value

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_eks_node_group.this
  ]

  tags = local.common_tags
}

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[
      length(data.tls_certificate.eks_oidc.certificates) - 1
    ].sha1_fingerprint
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-oidc"
    }
  )
}
