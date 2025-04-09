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

variable "secrets_names" {
  description = "Map of secret names for the application"
  type        = list(string)
  default     = []
}

variable "custom_role_statements" {
  description = "Custom IAM role statements"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = []
}

variable "linked_policies" {
  description = "Additional policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance"
  type        = string
  default     = "stop"
}

variable "key_name" {
  description = "Key pair name for the instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "user_data" {
  description = "script that will run when the machine starts"
  type        = string
  default     = ""
}

variable "metadata" {
  description = "Metadata options for the instance"
  type = object({
    http_tokens   = string
    http_endpoint = string
  })
  default = {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
}

variable "root_block_device" {
  description = "Root block device configuration"
  type = object({
    delete_on_termination = bool
    encrypted             = bool
    iops                  = number
    throughput            = number
    volume_size           = number
    volume_type           = string
  })
}

variable "ebs_block_device" {
  description = "Additional EBS block devices"
  type = list(object({
    device_name           = string
    name                  = optional(string, "")
    delete_on_termination = bool
    encrypted             = bool
    iops                  = number
    throughput            = number
    volume_size           = number
    volume_type           = string
  }))
  default = []
}

variable "sg" {
  description = "Security group IDs for the instance"
  type        = list(string)
}

variable "distro" {
  description = "Operating system to use (e.g., amazon-linux, ubuntu)"
  type        = string
  default     = "amazon-linux"
}

variable "arch" {
  description = "CPU architecture (e.g., x86_64, arm64)"
  type        = string
  default     = "x86_64"
}

variable "spot_enabled" {
  description = "Enable spot instances (true/false)"
  type        = bool
  default     = false
}

variable "ami_inputs" {
  description = "Map containing all inputs for AMI selection"
  type = object({
    executable_users = optional(list(string), null)     # Optional, defaults to ["self"]
    most_recent      = optional(bool, true)             # Optional, defaults to true
    owners           = optional(list(string), ["self"]) # Optional, defaults to ["self"]
    ami_name         = optional(string, null)
    filters = optional(list(object({
      name   = string
      values = list(string)
    })), []) # Default to null, so no filters are applied unless provided
  })
  default = null
}

variable "instance_interruption_behavior" {
  description = "Behavior when a spot instance is interrupted (terminate, stop, hibernate)"
  type        = string
  default     = "terminate"
}

variable "spot_instance_type" {
  description = "Spot instance type (one-time, persistent)"
  type        = string
  default     = "one-time"
}

variable "valid_until" {
  description = "Optional expiration date for persistent spot requests (ISO 8601 format)"
  type        = string
  default     = null
}
