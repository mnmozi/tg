locals {
  region      = var.region
  environment = var.environment

  mail_from_domain = "${var.mail_from_subdomain}.${var.domain}"

  dmarc_value = var.dmarc_rua != null ? "v=DMARC1; p=${var.dmarc_policy}; rua=mailto:${var.dmarc_rua}" : "v=DMARC1; p=${var.dmarc_policy}"

  create_sns_topic = var.enable_sns_events && var.sns_topic_arn == null
  sns_topic_arn    = var.enable_sns_events ? (var.sns_topic_arn != null ? var.sns_topic_arn : aws_sns_topic.events[0].arn) : null

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = var.domain },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

data "aws_caller_identity" "current" {}

# --------------------------------------------------------------------------
# Domain identity + DKIM
# --------------------------------------------------------------------------
resource "aws_sesv2_email_identity" "this" {
  email_identity         = var.domain
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }

  tags = local.tags
}

resource "aws_route53_record" "dkim" {
  count = 3

  zone_id = var.route53_zone_id
  name    = "${aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
}

# --------------------------------------------------------------------------
# Custom MAIL FROM domain
# --------------------------------------------------------------------------
resource "aws_sesv2_email_identity_mail_from_attributes" "this" {
  email_identity         = aws_sesv2_email_identity.this.email_identity
  mail_from_domain       = local.mail_from_domain
  behavior_on_mx_failure = "REJECT_MESSAGE"
}

resource "aws_route53_record" "mail_from_mx" {
  zone_id = var.route53_zone_id
  name    = local.mail_from_domain
  type    = "MX"
  ttl     = 600
  records = ["10 feedback-smtp.${var.region}.amazonses.com"]
}

resource "aws_route53_record" "mail_from_spf" {
  zone_id = var.route53_zone_id
  name    = local.mail_from_domain
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com ~all"]
}

# --------------------------------------------------------------------------
# DMARC
# --------------------------------------------------------------------------
resource "aws_route53_record" "dmarc" {
  zone_id = var.route53_zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = 600
  records = [local.dmarc_value]
}

# --------------------------------------------------------------------------
# Configuration set + event destinations
# --------------------------------------------------------------------------
resource "aws_sesv2_configuration_set" "this" {
  configuration_set_name = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}"

  delivery_options {
    tls_policy = var.tls_policy
  }

  reputation_options {
    reputation_metrics_enabled = true
  }

  sending_options {
    sending_enabled = true
  }

  tags = local.tags
}

resource "aws_sesv2_configuration_set_event_destination" "cloudwatch" {
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name
  event_destination_name = "cloudwatch"

  event_destination {
    enabled              = true
    matching_event_types = ["SEND", "REJECT", "BOUNCE", "COMPLAINT", "DELIVERY"]

    cloud_watch_destination {
      dimension_configuration {
        default_dimension_value = "default"
        dimension_name          = "ses:configuration-set"
        dimension_value_source  = "MESSAGE_TAG"
      }
    }
  }
}

resource "aws_sns_topic" "events" {
  count = local.create_sns_topic ? 1 : 0

  name = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}-ses-events"
  tags = local.tags
}

resource "aws_sesv2_configuration_set_event_destination" "sns" {
  count = var.enable_sns_events ? 1 : 0

  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name
  event_destination_name = "sns"

  event_destination {
    enabled              = true
    matching_event_types = ["BOUNCE", "COMPLAINT"]

    sns_destination {
      topic_arn = local.sns_topic_arn
    }
  }
}

# --------------------------------------------------------------------------
# IAM send policy (attach to existing roles)
# --------------------------------------------------------------------------
data "aws_iam_policy_document" "send" {
  statement {
    sid    = "SESSend"
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = [
      aws_sesv2_email_identity.this.arn,
      "arn:aws:ses:${var.region}:${data.aws_caller_identity.current.account_id}:configuration-set/${aws_sesv2_configuration_set.this.configuration_set_name}",
    ]

    dynamic "condition" {
      for_each = length(var.allowed_from_addresses) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "ses:FromAddress"
        values   = var.allowed_from_addresses
      }
    }
  }
}

resource "aws_iam_policy" "send" {
  name        = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}-ses-send"
  description = "Least-privilege SES send policy for ${var.domain}."
  policy      = data.aws_iam_policy_document.send.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "send" {
  count = var.attach_to_role_name != null ? 1 : 0

  role       = var.attach_to_role_name
  policy_arn = aws_iam_policy.send.arn
}
