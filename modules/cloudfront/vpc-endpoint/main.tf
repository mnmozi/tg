locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  identifier = (var.name == null || var.name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.name

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

resource "aws_cloudfront_vpc_origin" "endpoint" {
  vpc_origin_endpoint_config {
    name                   = local.identifier
    arn                    = var.destination_arn
    http_port              = var.http_port
    https_port             = var.https_port
    origin_protocol_policy = var.origin_protocol_policy

    origin_ssl_protocols {
      items    = var.origin_ssl_protocols
      quantity = length(var.origin_ssl_protocols) # Dynamically set quantity based on the list length.
    }
  }
}
