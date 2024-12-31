variable "region" {
  description = "The AWS region to deploy resources into"
  type        = string
}

variable "environment" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "owner" {
  type    = string
  default = null
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "required_tags" {
  description = "Mandatory tags that must be applied to all resources"
  type = object({
    project   = string
    component = string
  })
}

variable "tags" {
  description = "Additional tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "ingress_rules" {
  description = "List of regular ingress rules"
  type = list(object({
    cidr_blocks     = optional(list(string), []) # Optional field with default to an empty list
    prefix_list_ids = optional(list(string), [])
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
  }))
  default = []
}

variable "ingress_sg" {
  description = "Map of security group names and ingress details"
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    vpc_id      = optional(string, null) # Optional key with a default value of null
  }))
  default = {}
}
variable "ingress_sg_ids" {
  description = "List of regular ingress rules"
  type = list(object({
    cidr_blocks     = optional(list(string), []) # Optional field with default to an empty list
    prefix_list_ids = optional(list(string), [])
    security_groups = optional(list(string), [])
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    cidr_blocks = list(string)
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
}
variable "egress_sg" {
  description = "Map of security group names and ingress details"
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = {}
}
