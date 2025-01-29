variable "origin_ssl_protocols" {
  type        = list(string)
  default     = ["TLSv1.2"] # Default value, you can override this.
  description = "List of SSL protocols to allow for origin."
}
variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, production)"
  type        = string
}
variable "required_tags" {
  description = "Required tags for resources"
  type        = map(string)
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = null
}

variable "destination_arn" {
  description = "lb or ec2 arn"
  type        = string
  default     = null
}

variable "name" {
  description = "name of the vpc endpoint"
  type        = string
  default     = null
}

variable "http_port" {
  type        = number
  default     = 80
  description = "HTTP port for the origin."
}

variable "https_port" {
  type        = number
  default     = 443
  description = "HTTPS port for the origin."
}

variable "origin_protocol_policy" {
  type        = string
  default     = "https-only" # Example default, adjust as needed.
  description = "Protocol policy for the origin (e.g., http-only, https-only, match-viewer)."
}
