locals {
  environment = var.environment

  identifier = coalesce(var.name, format("%s-%s-%s", local.environment, var.required_tags.project, var.required_tags.component))

  policy_name = coalesce(var.policy_name, "${local.identifier}-policy")
  role_name   = coalesce(var.role_name, "${local.identifier}-role")

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

resource "aws_iam_policy" "this" {
  name        = local.policy_name
  description = var.policy_description
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.policy_statements
  })
  tags = local.tags
}

module "role" {
  source            = "github.com/mnmozi/tg//modules/ami-role"
  name              = local.role_name
  is_instance       = var.is_instance
  principal_service = var.principal_service
  policies = merge(
    var.additional_policies,
    { (local.policy_name) = aws_iam_policy.this.arn }
  )
  region = var.region
  tags   = local.tags
}
