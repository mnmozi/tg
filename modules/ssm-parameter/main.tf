locals {
  environment = var.environment

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

# Generated only when no explicit value is supplied. No special characters:
# consumers pass these through shell/env files (kargo.env) unquoted.
resource "random_password" "this" {
  count   = var.value == null ? 1 : 0
  length  = var.random_length
  special = false
}

resource "aws_ssm_parameter" "this" {
  name        = var.name
  description = var.description
  type        = var.type
  value       = var.value != null ? var.value : random_password.this[0].result
  tags        = local.tags
}
