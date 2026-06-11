variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
  type    = string
  default = null
}

variable "required_tags" {
  type = object({
    project   = string
    component = string
  })
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "domain" {
  type        = string
  description = "Domain to verify and send from (e.g. example.com)."
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID in which DKIM, MAIL FROM and DMARC records are created."
}

variable "mail_from_subdomain" {
  type        = string
  default     = "mail"
  description = "Subdomain prefix for the custom MAIL FROM domain. Full domain becomes <this>.<domain>."
}

variable "dmarc_policy" {
  type        = string
  default     = "quarantine"
  description = "DMARC policy (p=) value."

  validation {
    condition     = contains(["none", "quarantine", "reject"], var.dmarc_policy)
    error_message = "dmarc_policy must be one of: none, quarantine, reject."
  }
}

variable "dmarc_rua" {
  type        = string
  default     = null
  description = "Email address for DMARC aggregate reports (rua=). Omitted from the record when null."
}

variable "tls_policy" {
  type        = string
  default     = "REQUIRE"
  description = "TLS policy for the configuration set delivery options."

  validation {
    condition     = contains(["REQUIRE", "OPTIONAL"], var.tls_policy)
    error_message = "tls_policy must be one of: REQUIRE, OPTIONAL."
  }
}

variable "enable_sns_events" {
  type        = bool
  default     = false
  description = "Create/attach an SNS event destination for bounces and complaints."
}

variable "sns_topic_arn" {
  type        = string
  default     = null
  description = "Existing SNS topic ARN to publish bounce/complaint events to. When null and enable_sns_events is true, the module creates a topic."
}

variable "allowed_from_addresses" {
  type        = list(string)
  default     = []
  description = "If set, restricts the send IAM policy to these From addresses via the ses:FromAddress condition."
}

variable "attach_to_role_name" {
  type        = string
  default     = null
  description = "Name of an existing IAM role to attach the send policy to. When null, only the policy is created."
}
