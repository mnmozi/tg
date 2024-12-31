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

variable "max_image_count" {
  type        = number
  description = "The maximum number of images allowed per repository."
}

variable "protected_tags_and_number" {
  type        = map(number)
  description = "A map of tags to the maximum number of images to retain for each tag."
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

variable "scan_on_push" {
  type        = bool
  default     = false
  description = "Enable or disable image scanning on push to ECR repositories."
}
