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
  description = "Required tags for all resources."
  type        = map(string)
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "topic_name" {
  type = string
}

variable "email_addresses" {
  description = "Email endpoints subscribed to the topic (each must confirm once)."
  type        = list(string)
}
