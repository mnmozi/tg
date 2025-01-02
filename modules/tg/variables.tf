variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment for the resources (e.g., dev, prod)"
  type        = string
}

variable "required_tags" {
  description = "Required tags that need to be applied to all resources"
  type = object({
    project   = string
    component = string
  })
}

variable "tags" {
  description = "Additional tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = null
}

variable "tg_name" {
  description = "Name of the target group. Defaults to local.identifier if null or empty."
  type        = string
  default     = null
}

variable "target_port" {
  description = "Port for the target group to forward traffic to."
  type        = number
}

variable "protocol" {
  description = "Protocol used by the target group (e.g., HTTP, HTTPS)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created."
  type        = string
}

# Health Check Variables
variable "health_check_path" {
  description = "Path for health checks."
  type        = string
}

variable "health_check_protocol" {
  description = "Protocol for health checks (e.g., HTTP, HTTPS)."
  type        = string
  default     = "HTTP"
}

variable "health_check_interval" {
  description = "Interval for health checks in seconds."
  type        = number
  default     = 30
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks required to mark a target as unhealthy."
  type        = number
  default     = 2
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks required to mark a target as healthy."
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP status code to use when checking for a successful response from a target."
  type        = number
  default     = 200
}

# Stickiness Variables
variable "stickiness_cookie_duration" {
  description = "Cookie duration for sticky sessions in seconds."
  type        = number
  default     = 86400
}

variable "stickiness_enabled" {
  description = "Whether stickiness is enabled for the target group."
  type        = bool
  default     = false
}

variable "stickiness" {
  type = object({
    enabled         = bool
    cookie_duration = optional(string, "3600")      # Default value of 3600 seconds
    type            = optional(string, "lb_cookie") # Default to "lb_cookie"
  })
  default = {
    enabled         = false
    cookie_duration = "3600"
    type            = "lb_cookie"
  }
  description = "Configuration for stickiness settings"
}

variable "target_type" {
  type    = string
  default = "ip"
}
