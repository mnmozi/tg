locals {
  identifier = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}"
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, "Name" = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )

  key_name = var.key_name != null ? var.key_name : local.identifier
}

resource "aws_key_pair" "this" {
  key_name   = local.key_name
  public_key = var.public_key
  tags       = local.tags
}
