output "id" {
  description = "ECS service ID (ARN)."
  value       = aws_ecs_service.service.id
}

output "arn" {
  description = "ECS service ARN."
  value       = aws_ecs_service.service.id
}

output "name" {
  description = "ECS service name."
  value       = aws_ecs_service.service.name
}

output "cluster_name" {
  description = "Name of the cluster the service runs in (as passed in)."
  value       = var.cluster_name
}

output "task_definition" {
  description = "Task definition family:revision the service is pinned to."
  value       = aws_ecs_service.service.task_definition
}
