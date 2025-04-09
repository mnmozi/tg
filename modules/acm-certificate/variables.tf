variable "region" {
  description = "The AWS region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "required_tags" {
  description = "Required tags that must be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the resource, optional"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Set of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Method for validating the ACM certificate (DNS or EMAIL)"
  type        = string
  default     = "DNS"
}
