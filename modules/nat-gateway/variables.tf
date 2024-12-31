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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to include for all resources."
}
variable "subnet_id" {
  type        = string
  description = "Additional tags to include for all resources."
}
variable "route_table_id" {
  type        = string
  description = "Additional tags to include for all resources."
}
