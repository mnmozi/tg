locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  identifier = (var.lb_name == null || var.lb_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.lb_name

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
  flat_certificates = flatten([
    for listener_port, domains in var.certificates : [
      for domain in slice(domains, 1, length(domains)) : {
        listener_port = listener_port
        domain        = domain
      }
    ]
  ])
  first_certificates = {
    for listener_port, domains in var.certificates : listener_port => domains[0]
  }
}

data "aws_acm_certificate" "certificates" {
  for_each = { for cert in local.flat_certificates : "${cert.listener_port}-${cert.domain}" => cert }

  domain   = each.value.domain
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "default_certificates" {
  for_each = local.first_certificates

  domain   = each.value
  statuses = ["ISSUED"]
}

resource "aws_lb" "lb" {
  name               = local.identifier
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_group_ids
  subnets            = var.subnets

  idle_timeout           = var.idle_timeout
  enable_xff_client_port = false
  access_logs {
    bucket  = var.access_logs.bucket
    prefix  = var.access_logs.prefix
    enabled = var.access_logs.enabled
  }
  tags = local.tags
}

resource "aws_lb_listener" "listeners" {
  for_each = { for listener in var.listeners : "${listener.port}" => listener }

  load_balancer_arn = aws_lb.lb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = each.value.protocol == "HTTPS" ? data.aws_acm_certificate.default_certificates["${each.value.port}"].arn : null

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
  tags = local.tags
}

resource "aws_lb_listener_certificate" "additional_certificates" {
  for_each = {
    for key, value in data.aws_acm_certificate.certificates :
    key => key
  }

  listener_arn    = aws_lb_listener.listeners["${split("-", each.key)[0]}"].arn
  certificate_arn = data.aws_acm_certificate.certificates[each.key].arn
}

