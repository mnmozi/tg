output "cluster_id" {
  description = "Aurora cluster identifier."
  value       = module.instance.cluster_id
}

output "cluster_arn" {
  description = "Aurora cluster ARN."
  value       = module.instance.cluster_arn
}

output "cluster_endpoint" {
  description = "Writer endpoint."
  value       = module.instance.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint."
  value       = module.instance.cluster_reader_endpoint
}

output "cluster_port" {
  description = "Database port."
  value       = module.instance.cluster_port
}

output "cluster_instances" {
  description = "Map of cluster instances and their attributes."
  value       = module.instance.cluster_instances
}

output "master_user_secret" {
  description = "RDS-managed master user secret (empty unless manage_master_user_password = true)."
  value       = module.instance.cluster_master_user_secret
}
