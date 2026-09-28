output "target_resource_id" {
  description = "Application Auto Scaling target resource ID."
  value       = aws_appautoscaling_target.ecs_service_target.resource_id
}

output "policy_arns" {
  description = "Map of scaling policy key to policy ARN."
  value       = { for k, p in aws_appautoscaling_policy.ecs_scaling_policies : k => p.arn }
}

output "scheduled_action_arns" {
  description = "Map of scheduled action name to ARN."
  value       = { for k, a in aws_appautoscaling_scheduled_action.ecs_scheduled_actions : k => a.arn }
}
