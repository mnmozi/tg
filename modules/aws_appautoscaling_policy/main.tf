
resource "aws_appautoscaling_target" "ecs_service_target" {
  max_capacity       = var.ecs_service_target.max_capacity
  min_capacity       = var.ecs_service_target.min_capacity
  resource_id        = var.ecs_service_target.resource_id
  scalable_dimension = var.ecs_service_target.scalable_dimension
  service_namespace  = var.ecs_service_target.service_namespace
}

resource "aws_appautoscaling_scheduled_action" "ecs_scheduled_actions" {
  for_each           = { for action in var.scaling_schedules : action.name => action }
  name               = "${var.service_name}-${each.value.name}"
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  schedule           = each.value.schedule
  timezone           = each.value.timezone

  scalable_target_action {
    min_capacity = each.value.min_cap
    max_capacity = each.value.max_cap
  }
}

resource "aws_appautoscaling_policy" "ecs_scaling_policies" {
  for_each           = var.scaling_policies
  name               = "${var.service_name}-scaling-policy-${each.key}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.value.predefined_metric_type
    }
    target_value       = each.value.target_value
    scale_in_cooldown  = each.value.scale_in_cooldown
    scale_out_cooldown = each.value.scale_out_cooldown
  }
}
