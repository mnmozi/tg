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

resource "aws_lb_target_group" "tg" {
  name = (var.tg_name == null || var.tg_name == "") ? local.identifier : var.tg_name

  port        = var.target_port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type
  health_check {
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    interval            = var.health_check_interval
    unhealthy_threshold = var.unhealthy_threshold
    healthy_threshold   = var.healthy_threshold
    matcher             = var.health_check_matcher
  }

  stickiness {
    cookie_duration = var.stickiness_cookie_duration
    enabled         = var.stickiness_enabled
    type            = var.stickiness_type
  }

  tags = local.tags
}

