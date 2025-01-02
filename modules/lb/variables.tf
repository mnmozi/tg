variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment for the resources (e.g., dev, prod)"
  type        = string
}

variable "load_balancer_type" {
  description = "type of the lb"
  type        = string
  default     = "application"
}
variable "access_logs" {
  description = "Configuration for access logs"
  type = object({
    bucket  = string
    prefix  = optional(string, "")
    enabled = bool
  })
  default = {
    bucket  = ""
    prefix  = ""
    enabled = false
  }
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

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listeners"
  type        = string
}

variable "lb_name" {
  description = "name of the lb"
  type        = string
  default     = null
}

variable "internal" {
  description = "if the lb internal of external"
  type        = bool
}

variable "security_group_ids" {
  description = "Security Group ID for the load balancer"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets where the load balancer will be deployed"
  type        = list(string)
}

variable "enable_xff_client_port" {
  description = "Enable XFF client port support"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Idle timeout in seconds for the load balancer"
  type        = number
  default     = 600
}
variable "listeners" {
  description = "List of listener configurations for the load balancer"
  type = list(object({
    port     = number
    protocol = string
  }))
}
