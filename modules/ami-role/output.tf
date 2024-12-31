output "aws_iam_instance_profile" {
  description = "Details of the AWS IAM instance profile, or an empty object if not created."
  value       = try(aws_iam_instance_profile.default[0].name, {})
}

output "aws_iam_instance_profile_arn" {
  description = "The ARN of the AWS IAM instance profile, or an empty string if not created."
  value       = try(aws_iam_instance_profile.default[0].arn, "")
}

output "aws_iam_role_arn" {
  description = "The ARN of the AWS IAM role."
  value       = aws_iam_role.default.arn
}
