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
variable "listener_arn" {
  description = "ARN of the listener to attach the rule to."
  type        = string
}

variable "priority" {
  description = "Priority of the listener rule."
  type        = number
}

variable "action" {
  description = "Action configuration for the listener rule."
  type = object({
    type = string
    fixed_response = optional(object({
      content_type = string
      message_body = string
      status_code  = string
    }))
  })
}

variable "target_group_arn" {
  description = "ARN of the target group for forward actions."
  type        = string
  default     = null
}

variable "redirect_port" {
  description = "Port for redirect actions. Defaults to 443."
  type        = number
  default     = 443
}

variable "host_header" {
  description = "List of host header values for the condition."
  type        = list(string)
  default     = []
}

variable "http_headers" {
  description = "List of HTTP headers with their names and values for the condition."
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = []
}

variable "http_request_methods" {
  description = "List of HTTP request methods for the condition."
  type        = list(string)
  default     = []
}

variable "path_patterns" {
  description = "List of path patterns for the condition."
  type        = list(string)
  default     = []
}

variable "source_ips" {
  description = "List of source IPs for the condition."
  type        = list(string)
  default     = []
}

variable "query_strings" {
  description = "List of query strings for the condition."
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}
