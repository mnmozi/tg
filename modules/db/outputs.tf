output "identifier" {
  description = "RDS instance identifier."
  value       = module.instance.db_instance_identifier
}

output "arn" {
  description = "RDS instance ARN."
  value       = module.instance.db_instance_arn
}

output "endpoint" {
  description = "Connection endpoint in address:port format."
  value       = module.instance.db_instance_endpoint
}

output "address" {
  description = "Hostname of the RDS instance."
  value       = module.instance.db_instance_address
}

output "port" {
  description = "Database port."
  value       = module.instance.db_instance_port
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed master user secret (null unless manage_master_user_password = true)."
  value       = module.instance.db_instance_master_user_secret_arn
}
