# SES Module Design

**Date:** 2026-06-12
**Module path:** `modules/ses/`

## Purpose

A reusable Terraform module that provisions a production-ready Amazon SES
(SESv2) domain identity with DKIM signing, a custom MAIL FROM domain, DMARC,
deliverability tracking via a configuration set + event destinations, and a
least-privilege IAM policy for sending. All required DNS records are created
automatically in Route53.

Sending authentication is via **normal IAM roles** (the module outputs a
managed policy to attach to existing app/task roles) — no SMTP user or
password is created.

## Files

Matching repo convention (`modules/s3`, `modules/acm-certificate`):

- `provider.tf` — `terraform.required_providers` pinning `hashicorp/aws >= 5.89.0` + `provider "aws" { region = var.region }`
- `variables.tf`
- `main.tf`
- `output.tf`

## Resources

1. **Domain identity + DKIM**
   - `aws_sesv2_email_identity` for `var.domain`, Easy DKIM, `RSA_2048`.
   - 3 DKIM CNAME records created in Route53 (`<token>._domainkey.<domain>` → `<token>.dkim.amazonses.com`).
   - Configuration set attached as the identity's default config set.

2. **Custom MAIL FROM**
   - `aws_sesv2_email_identity_mail_from_attributes`.
   - Subdomain default `mail.<domain>` (`var.mail_from_subdomain`).
   - `behavior_on_mx_failure = "REJECT_MESSAGE"`.
   - Route53 records: MX (`10 feedback-smtp.<region>.amazonses.com`) and SPF TXT (`v=spf1 include:amazonses.com ~all`) on the MAIL FROM subdomain.

3. **DMARC**
   - Route53 TXT record at `_dmarc.<domain>`.
   - Value: `v=DMARC1; p=<var.dmarc_policy>; rua=mailto:<var.dmarc_rua>` (rua omitted if not set).
   - Default policy `quarantine`.

4. **Configuration set**
   - `aws_sesv2_configuration_set`.
   - `reputation_options.reputation_metrics_enabled = true`.
   - `delivery_options.tls_policy = var.tls_policy` (default `REQUIRE`).
   - `sending_options.sending_enabled = true`.

5. **Event destinations** (`aws_sesv2_configuration_set_event_destination`)
   - **CloudWatch** (always on): matching events `SEND, REJECT, BOUNCE, COMPLAINT, DELIVERY`, dimension source `MESSAGE_TAG` default `ses:configuration-set`.
   - **SNS** (optional, `var.enable_sns_events`): module creates an SNS topic for `BOUNCE, COMPLAINT` when enabled and no `var.sns_topic_arn` is provided; otherwise uses the provided topic ARN.

6. **IAM send policy** (replaces SMTP credentials)
   - `aws_iam_policy` granting `ses:SendEmail` + `ses:SendRawEmail`.
   - `Resource` scoped to the identity ARN and the configuration set ARN.
   - Optional condition on `ses:FromAddress` if `var.allowed_from_addresses` is set.
   - Optional attachment to an existing role: when `var.attach_to_role_name` is set, an `aws_iam_role_policy_attachment` binds the policy to that role.
   - Policy ARN is always output for attaching elsewhere.

## Inputs

| Name | Type | Default | Notes |
|------|------|---------|-------|
| `region` | string | — | |
| `environment` | string | — | |
| `owner` | string | `null` | |
| `required_tags` | object({project, component}) | — | |
| `tags` | map(string) | `{}` | |
| `domain` | string | — | Domain to verify |
| `route53_zone_id` | string | — | Hosted zone for DNS records |
| `mail_from_subdomain` | string | `"mail"` | Prefix; full = `<this>.<domain>` |
| `dmarc_policy` | string | `"quarantine"` | `none`/`quarantine`/`reject` (validated) |
| `dmarc_rua` | string | `null` | Aggregate report email |
| `tls_policy` | string | `"REQUIRE"` | `REQUIRE`/`OPTIONAL` |
| `enable_sns_events` | bool | `false` | Create/attach SNS event destination |
| `sns_topic_arn` | string | `null` | BYO topic; else module creates one |
| `allowed_from_addresses` | list(string) | `[]` | Restrict send IAM policy by From |
| `attach_to_role_name` | string | `null` | Existing IAM role to attach send policy |

## Outputs

- `identity_arn`
- `dkim_tokens`
- `configuration_set_name`
- `mail_from_domain`
- `send_policy_arn`
- `sns_topic_arn` (null when SNS disabled)

## Locals / tagging

Follow `modules/s3` pattern: `local.tags = merge(required_tags, tags, {environment, Name}, owner?)`.

## Production rationale

- Enforced TLS on delivery (`REQUIRE`).
- `REJECT_MESSAGE` on MAIL FROM MX failure.
- Reputation metrics enabled.
- DKIM RSA-2048.
- Least-privilege IAM policy scoped to this identity + config set, attachable to existing roles (no long-lived SMTP secret).

## Out of scope (YAGNI)

Dedicated IP pools, suppression-list management, SES receiving rules, SMTP credentials.
