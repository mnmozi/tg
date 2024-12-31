variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}

variable "lt_name" {
  description = "Launch template name"
  type        = string
  default     = null
}

variable "iam_policy_name" {
  description = "IAM policy name"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "IAM role name"
  type        = string
  default     = null
}

variable "arch" {
  description = "Architecture (x86_64 or arm64)"
  type        = string
  default     = "x86_64"
}

variable "distro" {
  description = "Operating system distribution (e.g., amazon-linux, ubuntu)"
  type        = string
}

variable "required_tags" {
  type = object({
    project   = string
    component = string
  })
  description = "The required tags that must be included for all resources."
}


variable "tags" {
  description = "Additional tags for the resources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = null
}

variable "secrets_names" {
  description = "List of secret names in Secrets Manager"
  type        = list(string)
  default     = []
}

variable "custom_role_statements" {
  description = "Additional custom IAM policy statements"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = []
}

variable "instance_type" {
  description = "Instance type for the launch template"
  type        = string
}

variable "key_name" {
  description = "Key pair name for the EC2 instance"
  type        = string
  default     = null
}

variable "spot_enabled" {
  description = "Enable spot instances"
  type        = bool
  default     = false
}

variable "spot_instance_type" {
  description = "Spot instance type (persistent or one-time)"
  type        = string
  default     = "one-time"
}

variable "instance_interruption_behavior" {
  description = "Behavior when a spot instance is interrupted (e.g., terminate, stop)"
  type        = string
  default     = "terminate"
}

variable "valid_until" {
  description = "Spot instance valid until date"
  type        = string
  default     = null
}

variable "cpu_credits" {
  description = "CPU credit option for T-series instances"
  type        = string
  default     = "unlimited"
}

variable "disable_api_stop" {
  description = "Disable the ability to stop the instance via API"
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "Disable the ability to terminate the instance via API"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = false
}

variable "metadata_options" {
  description = "Metadata options for the instance"
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }
}

variable "monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with the instance"
  type        = bool
  default     = false
}

variable "sg_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "block_device_mappings" {
  description = "Block device mappings for the launch template"
  type = list(object({
    device_name = string
    ebs = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = number
      throughput            = number
      volume_size           = number
      volume_type           = string
    })
  }))
  default = []
}

variable "iam" {
  description = "Custom AMI ID (if provided)"
  type        = string
  default     = null
}

variable "default_version" {
  description = "Default version for the launch template"
  type        = number
  default     = 1
}
