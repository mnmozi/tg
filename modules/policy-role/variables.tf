variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, prod)"
  type        = string
}

variable "owner" {
  description = "Optional owner tag"
  type        = string
  default     = null
}

variable "required_tags" {
  description = "Required tags to be applied to resources"
  type = object({
    project   = string
    component = string
  })
}

variable "tags" {
  description = "Additional tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Base name for the role and policy. If not provided, auto-generated from environment and tags"
  type        = string
  default     = null
}

variable "role_name" {
  description = "Override the role name. If not provided, uses name-role"
  type        = string
  default     = null
}

variable "policy_name" {
  description = "Override the policy name. If not provided, uses name-policy"
  type        = string
  default     = null
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Managed by Terraform"
}

variable "policy_statements" {
  description = "List of IAM policy statements"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
}

variable "principal_service" {
  description = "List of AWS services allowed to assume this role"
  type        = list(string)
}

variable "is_instance" {
  description = "Whether to create an instance profile for the role"
  type        = bool
  default     = false
}

variable "additional_policies" {
  description = "Map of additional policy ARNs to attach to the role"
  type        = map(string)
  default     = {}
}
