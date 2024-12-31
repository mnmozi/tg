locals {
  # Key variables for naming and organization
  region       = var.region
  environment  = var.environment
  service_name = "${var.required_tags.project}-${var.required_tags.component}"

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )


  # Image lifecycle policies
  max_image_count           = var.max_image_count
  protected_tags_and_counts = var.protected_tags_and_number

  # Rule for untagged images
  untagged_image_rule = [
    {
      rulePriority = 50
      description  = "Remove untagged images"
      selection = {
        tagStatus   = "untagged"
        countType   = "imageCountMoreThan"
        countNumber = 1
      }
      action = {
        type = "expire"
      }
    }
  ]

  # Rules for protected tags
  protected_tag_rules_count = [
    for tag, count in local.protected_tags_and_counts : {
      rulePriority = index(keys(local.protected_tags_and_counts), tag) + 1
      description  = "Protect images tagged with ${tag}"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = [tag]
        countType     = "imageCountMoreThan"
        countNumber   = count
      }
      action = {
        type = "expire"
      }
    }
  ]
}

# ECR Repository
resource "aws_ecr_repository" "ecr" {
  name                 = local.service_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = local.tags
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "lifecycle" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    rules = concat(local.protected_tag_rules_count, local.untagged_image_rule)
  })

  depends_on = [aws_ecr_repository.ecr]
}
