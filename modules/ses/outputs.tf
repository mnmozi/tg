output "identity_arn" {
  value = aws_sesv2_email_identity.this.arn
}

output "dkim_tokens" {
  value = aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens
}

output "configuration_set_name" {
  value = aws_sesv2_configuration_set.this.configuration_set_name
}

output "mail_from_domain" {
  value = local.mail_from_domain
}

output "send_policy_arn" {
  value = aws_iam_policy.send.arn
}

output "sns_topic_arn" {
  value = local.sns_topic_arn
}
