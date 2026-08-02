variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, prod)"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role mapped to the Kubernetes service account"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name the pod identity association is created for"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account"
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account name to grant the role to"
  type        = string
}

variable "policy_arns" {
  description = "Map of name => IAM policy ARN to attach to the role"
  type        = map(string)
  default     = {}
}

variable "inline_policies" {
  description = "Map of policy_name => JSON policy text. Each is created as a customer-managed IAM policy and attached to the role. Use when a workload needs a policy not published as AWS-managed (e.g. AWS Load Balancer Controller)."
  type        = map(string)
  default     = {}
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
