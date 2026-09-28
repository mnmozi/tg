output "state_bucket" {
  description = "Name of the state bucket."
  value       = module.remote_state.state_bucket.bucket
}

output "dynamodb_table" {
  description = "Name of the DynamoDB lock table."
  value       = module.remote_state.dynamodb_table.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting state."
  value       = module.remote_state.kms_key.arn
}
