
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