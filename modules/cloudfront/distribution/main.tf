locals {
  region      = var.region
  environment = var.environment

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

# Dynamically create data blocks for cache policies
data "aws_cloudfront_cache_policy" "selected" {
  for_each = var.cache_policy_ids
  name     = each.value
}

# Dynamically create data blocks for origin request policies
data "aws_cloudfront_origin_request_policy" "selected" {
  for_each = var.origin_request_policy_ids
  name     = each.value
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  tags            = local.tags
  aliases         = var.aliases

  dynamic "origin" {
    for_each = var.origin_config
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.origin_id
      connection_attempts      = origin.value.connection_attempts
      connection_timeout       = origin.value.connection_timeout
      origin_access_control_id = origin.value.origin_access_control_id

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []
        content {
          http_port              = lookup(custom_origin_config.value, "http_port", 80)
          https_port             = lookup(custom_origin_config.value, "https_port", 443)
          origin_protocol_policy = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols   = custom_origin_config.value.origin_ssl_protocols
        }
      }

      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_headers", [])
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  # Generate ordered cache behaviors dynamically
  dynamic "ordered_cache_behavior" {
    for_each = tomap({ for k, v in var.ordered_cache_behaviors : k => v if k != "default" })
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      cache_policy_id = try(
        data.aws_cloudfront_cache_policy.selected[ordered_cache_behavior.key].id,
        null
      )

      origin_request_policy_id = try(
        data.aws_cloudfront_origin_request_policy.selected[ordered_cache_behavior.key].id,
        null
      )
    }
  }

  # Use the "default" key for default_cache_behavior
  default_cache_behavior {
    target_origin_id         = var.ordered_cache_behaviors["default"].target_origin_id
    allowed_methods          = var.ordered_cache_behaviors["default"].allowed_methods
    cached_methods           = var.ordered_cache_behaviors["default"].cached_methods
    compress                 = var.ordered_cache_behaviors["default"].compress
    viewer_protocol_policy   = var.ordered_cache_behaviors["default"].viewer_protocol_policy
    cache_policy_id          = data.aws_cloudfront_cache_policy.selected["default"].id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.selected["default"].id
  }

  viewer_certificate {
    acm_certificate_arn      = var.viewer_certificate.acm_certificate_arn
    ssl_support_method       = var.viewer_certificate.ssl_support_method
    minimum_protocol_version = var.viewer_certificate.minimum_protocol_version
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
