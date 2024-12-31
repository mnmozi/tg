locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  service_identifier = (var.service_name == null || var.service_name == "") ? "${var.required_tags.project}-${var.required_tags.component}" : var.service_name

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.service_identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

data "aws_ecs_task_definition" "first_task_definition" {
  task_definition = var.task_definition
}

data "aws_ecs_task_definition" "recent_task_definition" {
  task_definition = data.aws_ecs_task_definition.first_task_definition.family
  depends_on      = [data.aws_ecs_task_definition.first_task_definition]
}

resource "aws_ecs_service" "service" {
  name    = local.service_identifier
  cluster = var.cluster_name

  task_definition = "${data.aws_ecs_task_definition.first_task_definition.family}:${max("${data.aws_ecs_task_definition.first_task_definition.revision}", "${data.aws_ecs_task_definition.recent_task_definition.revision}")}"

  desired_count                     = var.desired_count
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  enable_execute_command            = var.enable_execute_command
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_providers
    content {
      base              = lookup(capacity_provider_strategy.value, "base", null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = lookup(capacity_provider_strategy.value, "weight", null)
    }
  }


  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.sg
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }


  lifecycle {
    ignore_changes = [desired_count]
  }
  wait_for_steady_state = var.wait_for_steady_state
  tags                  = local.tags
}

