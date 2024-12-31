output "arn" {
  value = aws_ecs_task_definition.service_task_definition.arn
}
output "container_names" {
  value = var.container_names
}

output "container_ports" {
  value = var.containers_port
}
output "family" {
  value = aws_ecs_task_definition.service_task_definition.family
}
