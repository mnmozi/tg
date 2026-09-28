output "arn" {
  description = "Listener rule ARN."
  value       = aws_lb_listener_rule.lr.arn
}

output "id" {
  description = "Listener rule ID."
  value       = aws_lb_listener_rule.lr.id
}
