variable "required_tags" {
  description = "Required tags for resources"
  type        = map(string)
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "ami_name" {
  description = "Name of the AMI"
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "ebs_block_device" {
  description = "list of the ebs devices"
  type        = list(string)
}

variable "environment" {
  description = "Environment (e.g., dev, staging, production)"
  type        = string
}
