resource "aws_sns_topic" "this" {
  name = var.topic_name
  tags = merge(var.required_tags, var.tags, { environment = var.environment })
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.email_addresses)
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}
