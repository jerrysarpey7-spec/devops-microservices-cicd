provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Project     = var.project_name
        Environment = "shared"
        ManagedBy   = "Terraform"
      }
    )
  }
}

data "aws_caller_identity" "current" {}