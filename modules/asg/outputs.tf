output "id" {
  description = "Auto Scaling Group ID."
  value       = aws_autoscaling_group.asg.id
}

output "arn" {
  description = "Auto Scaling Group ARN."
  value       = aws_autoscaling_group.asg.arn
}

output "name" {
  description = "Auto Scaling Group name."
  value       = aws_autoscaling_group.asg.name
}
