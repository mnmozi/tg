variable "zone_name" {
  description = "The name of the Route 53 hosted zone."
  type        = string
}

variable "vpc_associations" {
  description = "List of VPC associations for the hosted zone."
  type = list(object({
    vpc_id     = string
    vpc_region = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the Route 53 hosted zone."
  type        = map(string)
  default     = {}
}

variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}
variable "environment" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "owner" {
  type    = string
  default = null
}
variable "required_tags" {
  type = object({
    project   = string
    component = string
  })
  description = "The required tags that must be included for all resources."
}