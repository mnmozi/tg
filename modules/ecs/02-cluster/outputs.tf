output "cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.cluster_name
}

output "cluster_arn" {
  description = "ECS cluster ARN."
  value       = module.ecs.cluster_arn
}

output "cluster_id" {
  description = "ECS cluster ID."
  value       = module.ecs.cluster_id
}

output "capacity_providers" {
  description = "Map of capacity providers created for the cluster (ASG-backed)."
  value       = module.ecs.capacity_providers
}
