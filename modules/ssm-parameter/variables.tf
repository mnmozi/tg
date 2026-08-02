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

variable "name" {
  description = "Full SSM parameter name (e.g. /kargo/db-password)"
  type        = string
}

variable "description" {
  type    = string
  default = ""
}

variable "type" {
  description = "SSM parameter type"
  type        = string
  default     = "SecureString"
}

variable "value" {
  description = "Explicit parameter value. Leave null to generate a random secret."
  type        = string
  default     = null
  sensitive   = true
}

variable "random_length" {
  description = "Length of the generated secret when value is null"
  type        = number
  default     = 40
}
