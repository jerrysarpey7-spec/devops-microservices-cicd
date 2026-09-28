locals {
  repository_map = {
    for repository_name in var.repository_names :
    repository_name => "${var.project_name}/${var.environment}/${repository_name}"
  }

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "container-registry"
    },
    var.tags
  )
}

resource "aws_ecr_repository" "this" {
  for_each = local.repository_map

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  tags = merge(
    local.common_tags,
    {
      Name    = each.value
      Service = each.key
    }
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after the retention period"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_retention_days
        }

        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Retain only the most recent images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.maximum_image_count
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}