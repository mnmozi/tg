output "id" {
  description = "Replication group ID."
  value       = aws_elasticache_replication_group.default.id
}

output "arn" {
  description = "Replication group ARN."
  value       = aws_elasticache_replication_group.default.arn
}

output "primary_endpoint_address" {
  description = "Primary (writer) endpoint address."
  value       = aws_elasticache_replication_group.default.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Reader endpoint address."
  value       = aws_elasticache_replication_group.default.reader_endpoint_address
}

output "port" {
  description = "Port the replication group listens on."
  value       = aws_elasticache_replication_group.default.port
}
