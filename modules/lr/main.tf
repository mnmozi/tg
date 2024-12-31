locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  identifier = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}"

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

resource "aws_lb_listener_rule" "lr" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type = var.action.type

    # Forward action
    target_group_arn = var.action.type == "forward" ? var.target_group_arn : null

    # Redirect action
    dynamic "redirect" {
      for_each = var.action.type == "redirect" ? [var.action] : []
      content {
        protocol    = "HTTPS"
        port        = var.redirect_port
        host        = "#{host}"
        path        = "#{path}"
        query       = "#{query}"
        status_code = "HTTP_301"
      }
    }

    # Fixed-response action
    dynamic "fixed_response" {
      for_each = var.action.type == "fixed-response" ? [var.action.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  # Host header condition
  dynamic "condition" {
    for_each = var.host_header != null && length(var.host_header) > 0 ? [1] : []
    content {
      host_header {
        values = var.host_header
      }
    }
  }

  # HTTP headers condition
  dynamic "condition" {
    for_each = var.http_headers != null && length(var.http_headers) > 0 ? var.http_headers : []
    content {
      http_header {
        http_header_name = condition.value.name
        values           = condition.value.values
      }
    }
  }

  # HTTP request methods condition
  dynamic "condition" {
    for_each = var.http_request_methods != null && length(var.http_request_methods) > 0 ? [1] : []
    content {
      http_request_method {
        values = var.http_request_methods
      }
    }
  }

  # Path pattern condition
  dynamic "condition" {
    for_each = var.path_patterns != null && length(var.path_patterns) > 0 ? [1] : []
    content {
      path_pattern {
        values = var.path_patterns
      }
    }
  }

  # Source IP condition
  dynamic "condition" {
    for_each = var.source_ips != null && length(var.source_ips) > 0 ? [1] : []
    content {
      source_ip {
        values = var.source_ips
      }
    }
  }

  # Query string condition
  dynamic "condition" {
    for_each = var.query_strings != null && length(var.query_strings) > 0 ? var.query_strings : []
    content {
      query_string {
        key   = condition.value.key
        value = condition.value.value
      }
    }
  }

  tags = local.tags
}
