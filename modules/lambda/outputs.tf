output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function (for API Gateway)"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = module.iam_role.aws_iam_role_arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.name
}

output "eventbridge_rule_arns" {
  description = "ARNs of the EventBridge rules"
  value       = { for k, v in aws_cloudwatch_event_rule.this : k => v.arn }
}
