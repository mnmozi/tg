variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, production)"
  type        = string
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

variable "asg_name" {
  description = "Custom name for the Auto Scaling Group. If not provided, a default name will be generated."
  type        = string
  default     = null
}

variable "required_tags" {
  description = "Required tags that must be applied to the resources."
  type        = map(string)
}


variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
}

variable "health_check_grace_period" {
  description = "Time (in seconds) that the Auto Scaling Group waits before checking the health status of an instance."
  type        = number
}

variable "health_check_type" {
  description = "Type of health check to use for the Auto Scaling Group. Valid values are 'EC2' or 'ELB'."
  type        = string
  default     = "EC2"
}

variable "vpc_zone_identifier" {
  description = "VPC subnets"
  type        = list(string)
}

variable "force_delete" {
  description = "Whether to forcefully delete the Auto Scaling Group, including its instances."
  type        = bool
  default     = false
}

variable "desired_capacity_type" {
  description = "Specifies whether the desired capacity is expressed as a number or a percentage."
  type        = string
  default     = "units"
}

variable "capacity_rebalance" {
  description = "Whether capacity rebalance is enabled for the Auto Scaling Group."
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Instance type for the Auto Scaling Group. If not set, mixed instance policy is applied."
  type        = string
  default     = ""
}

variable "launch_template_name" {
  description = "Name of the launch template to use for the Auto Scaling Group."
  type        = string
  default     = ""
}

variable "launch_template" {
  description = "Launch template configuration for the Auto Scaling Group."
  type = object({
    id      = optional(string)
    version = optional(string, "$Latest")
  })
  default = {}
}

variable "mixed_instance_policy" {
  description = "Configuration for mixed instance policy."
  type = object({
    on_demand_base_capacity                  = optional(number, 0)
    on_demand_percentage_above_base_capacity = optional(number, 0)
    spot_allocation_strategy                 = optional(string, "price-capacity-optimized")
    spot_instance_pools                      = optional(number, 0)
    override = list(object({
      instance_type     = string
      weighted_capacity = number
    }))
  })
  default = null
}

variable "target_groups_names" {
  description = "List of target group names for the Auto Scaling Group."
  type        = list(string)
  default     = []
}

variable "target_groups_arns" {
  description = "List of target group ARNs for the Auto Scaling Group."
  type        = list(string)
  default     = []
}
