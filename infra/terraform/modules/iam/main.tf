data "aws_partition" "current" {}

locals {
  cluster_role_name = "${var.project_name}-${var.environment}-eks-cluster-role"
  node_role_name    = "${var.project_name}-${var.environment}-eks-node-role"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "iam"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    sid     = "AllowEKSService"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    sid     = "AllowEC2Service"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name                 = local.cluster_role_name
  description          = "IAM role used by the ${var.environment} EKS control plane."
  assume_role_policy   = data.aws_iam_policy_document.eks_cluster_assume_role.json
  permissions_boundary = var.permissions_boundary_arn
  max_session_duration = 3600

  tags = merge(
    local.common_tags,
    {
      Name = local.cluster_role_name
      Role = "eks-cluster"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node" {
  name                 = local.node_role_name
  description          = "IAM role used by the ${var.environment} EKS worker nodes."
  assume_role_policy   = data.aws_iam_policy_document.eks_node_assume_role.json
  permissions_boundary = var.permissions_boundary_arn
  max_session_duration = 3600

  tags = merge(
    local.common_tags,
    {
      Name = local.node_role_name
      Role = "eks-node"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count = var.attach_vpc_cni_policy ? 1 : 0

  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_instance_profile" "eks_node" {
  name = "${var.project_name}-${var.environment}-eks-node-profile"
  role = aws_iam_role.eks_node.name

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-eks-node-profile"
      Role = "eks-node"
    }
  )
}