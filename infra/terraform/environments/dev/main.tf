
module "vpc" {
  source = "../../modules/vpc"

  project_name               = var.project_name
  environment                = var.environment
  vpc_cidr                   = var.vpc_cidr
  availability_zones         = var.availability_zones
  public_subnet_cidrs        = var.public_subnet_cidrs
  private_subnet_cidrs       = var.private_subnet_cidrs
  enable_nat_gateway         = var.enable_nat_gateway
  single_nat_gateway         = var.single_nat_gateway
  enable_s3_gateway_endpoint = var.enable_s3_gateway_endpoint
  tags                       = var.tags
}
module "ecr" {
  source = "../../modules/ecr"

  project_name                  = var.project_name
  environment                   = var.environment
  repository_names              = var.service_names
  image_tag_mutability          = var.ecr_image_tag_mutability
  scan_on_push                  = var.ecr_scan_on_push
  encryption_type               = var.ecr_encryption_type
  untagged_image_retention_days = var.ecr_untagged_image_retention_days
  maximum_image_count           = var.ecr_maximum_image_count
  tags                          = var.tags
}

module "iam" {
  source = "../../modules/iam"

  project_name             = var.project_name
  environment              = var.environment
  attach_vpc_cni_policy    = var.iam_attach_vpc_cni_policy
  permissions_boundary_arn = var.iam_permissions_boundary_arn
  tags                     = var.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.eks_cluster_name
  kubernetes_version = var.eks_kubernetes_version

  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn

  endpoint_private_access = var.eks_endpoint_private_access
  endpoint_public_access  = var.eks_endpoint_public_access
  public_access_cidrs     = var.eks_public_access_cidrs

  cloudwatch_log_retention_days = var.eks_cloudwatch_log_retention_days

  node_group_name     = "general"
  node_instance_types = var.eks_node_instance_types
  node_capacity_type  = var.eks_node_capacity_type
  node_min_size       = var.eks_node_min_size
  node_desired_size   = var.eks_node_desired_size
  node_max_size       = var.eks_node_max_size
  node_disk_size      = var.eks_node_disk_size

  node_labels = {
    workload    = "general"
    environment = var.environment
  }

  tags = var.tags
}



module "github_actions" {
  source = "../../modules/github-actions"

  project_name      = var.project_name
  environment       = var.environment
  github_owner      = var.github_owner
  github_repository = var.github_repository
  allowed_branch    = var.github_deployment_branch
  eks_cluster_name  = module.eks.cluster_name
  kubernetes_namespace = (
    var.kubernetes_application_namespace
  )

  github_oidc_provider_arn = var.github_oidc_provider_arn
  ecr_repository_arns      = toset(values(module.ecr.repository_arns))
  permissions_boundary_arn = var.iam_permissions_boundary_arn

  tags = var.tags
}