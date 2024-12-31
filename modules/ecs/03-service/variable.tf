variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "service_name" {
  description = "Optional custom name for the ECS service"
  type        = string
  default     = null
}

variable "required_tags" {
  type = object({
    project   = string
    component = string
  })
  description = "The required tags that must be included for all resources."
}
variable "enable_execute_command" {
  type    = bool
  default = false
}

variable "tags" {
  description = "Additional tags to merge with required tags"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the service (optional)"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "task_definition" {
  description = "Task definition ARN or family for the ECS service"
  type        = string
}

variable "desired_count" {
  description = "The desired number of tasks for the service"
  type        = number
  default     = 1
}

variable "health_check_grace_period_seconds" {
  description = "Time (in seconds) to ignore unhealthy load balancer health checks"
  type        = number
  default     = null
}

variable "capacity_providers" {
  description = "List of capacity provider strategies"
  type = list(object({
    base              = optional(number)
    capacity_provider = string
    weight            = optional(number)
  }))
  default = []
}

variable "deployment_maximum_percent" {
  description = "The upper limit (as a percentage) of the number of tasks that can run during a deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage) of the number of tasks that must remain healthy during a deployment"
  type        = number
  default     = 100
}

variable "subnets" {
  description = "List of subnets for the ECS service"
  type        = list(string)
}

variable "sg" {
  description = "List of security group IDs for the ECS service"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the ECS tasks"
  type        = bool
  default     = false
}

variable "load_balancers" {
  description = "List of load balancer configurations"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "wait_for_steady_state" {
  description = "Whether to wait for the ECS service to reach a steady state"
  type        = bool
  default     = true
}
