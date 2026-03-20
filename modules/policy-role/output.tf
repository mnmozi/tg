output "role_arn" {
  description = "ARN of the IAM role"
  value       = module.role.aws_iam_role_arn
}

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = aws_iam_policy.this.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile, or null if not created"
  value       = module.role.aws_iam_instance_profile
}

output "instance_profile_arn" {
  description = "ARN of the instance profile, or null if not created"
  value       = module.role.aws_iam_instance_profile_arn
}
