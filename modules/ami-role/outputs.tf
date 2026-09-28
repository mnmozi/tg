output "aws_iam_instance_profile" {
  description = "Name of the AWS IAM instance profile, or null if not created."
  value       = var.is_instance ? aws_iam_instance_profile.default[0].name : null
}

output "aws_iam_instance_profile_arn" {
  description = "The ARN of the AWS IAM instance profile, or null if not created."
  value       = var.is_instance ? aws_iam_instance_profile.default[0].arn : null
}

output "aws_iam_role_arn" {
  description = "The ARN of the created IAM role."
  value       = aws_iam_role.default.arn
}
