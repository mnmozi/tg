locals {
  region      = var.region
  environment = var.environment

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}


resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  subject_alternative_names = var.subject_alternative_names

  validation_method = var.validation_method

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

