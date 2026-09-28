variable "region" {
  type        = string
  description = "AWS region (IAM is global; used by the provider only)."
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "role_name" {
  type    = string
  default = "dev-dynatrace-aws-monitoring"
}

variable "dynatrace_principal" {
  type        = string
  default     = "arn:aws:iam::314146291599:root" # Dynatrace SaaS hyperscaler-connections account
  description = "AWS principal Dynatrace assumes the role from."
}

variable "external_id" {
  type        = string
  description = "The connection settings objectId from builtin:hyperscaler-authentication.connections.aws (not secret)."
}

variable "required_tags" {
  type = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
