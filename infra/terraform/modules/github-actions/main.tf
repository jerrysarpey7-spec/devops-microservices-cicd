data "aws_partition" "current" {}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

locals {
  role_name = "${var.project_name}-${var.environment}-github-actions"

  github_subject = join(
    ":",
    [
      "repo",
      "${var.github_owner}/${var.github_repository}",
      "ref",
      "refs/heads/${var.allowed_branch}"
    ]
  )

  github_oidc_provider_arn = (
    var.github_oidc_provider_arn != null
    ? var.github_oidc_provider_arn
    : aws_iam_openid_connect_provider.github[0].arn
  )

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "github-actions-cicd"
    },
    var.tags
  )
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.github_oidc_provider_arn == null ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-github-actions-oidc"
    }
  )
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowGitHubActionsFromDevelop"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        local.github_oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_subject
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name                 = local.role_name
  description          = "Short-lived GitHub Actions role for ECR and EKS deployments."
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  permissions_boundary = var.permissions_boundary_arn
  max_session_duration = 3600

  tags = merge(
    local.common_tags,
    {
      Name = local.role_name
    }
  )
}

data "aws_iam_policy_document" "github_actions" {
  #checkov:skip=CKV_AWS_356:ECR GetAuthorizationToken does not support resource-level permissions.
  statement {
    sid    = "AllowECRAuthentication"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECRImagePushAndRead"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = sort(tolist(var.ecr_repository_arns))
  }

  statement {
    sid    = "AllowEKSClusterDiscovery"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster"
    ]

    resources = [
      data.aws_eks_cluster.this.arn
    ]
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "${local.role_name}-policy"
  description = "Least-privilege ECR push and EKS discovery permissions."
  policy      = data.aws_iam_policy_document.github_actions.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.role_name}-policy"
    }
  )
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"

  tags = merge(
    local.common_tags,
    {
      Name = local.role_name
    }
  )
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.github_actions.arn

  policy_arn = join(
    "",
    [
      "arn:",
      data.aws_partition.current.partition,
      ":eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
    ]
  )

  access_scope {
    type = "namespace"

    namespaces = [
      var.kubernetes_namespace
    ]
  }

  depends_on = [
    aws_eks_access_entry.github_actions
  ]
}