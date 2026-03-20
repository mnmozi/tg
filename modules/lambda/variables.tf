variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., dev, prod)."
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
  description = "Required tags for all resources."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources."
}

# Naming overrides
variable "function_name" {
  type    = string
  default = null
}

variable "iam_role_name" {
  type    = string
  default = null
}

variable "iam_policy_name" {
  type    = string
  default = null
}

# Runtime configuration
variable "runtime" {
  type        = string
  default     = null
  description = "Lambda runtime (e.g., python3.12, nodejs20.x). Required for Zip package type."
}

variable "handler" {
  type        = string
  default     = null
  description = "Function entrypoint (e.g., index.handler). Required for Zip package type."
}

variable "architecture" {
  type        = string
  default     = "x86_64"
  description = "Instruction set architecture (x86_64 or arm64)."
}

variable "timeout" {
  type        = number
  default     = 30
  description = "Amount of time the function can run in seconds."
}

variable "memory_size" {
  type        = number
  default     = 128
  description = "Amount of memory in MB available to the function."
}

# Package configuration
variable "package_type" {
  type        = string
  default     = "Zip"
  description = "Lambda deployment package type: Zip or Image."
}

variable "filename" {
  type        = string
  default     = null
  description = "Path to the function zip file (Zip package type)."
}

variable "source_code_hash" {
  type        = string
  default     = null
  description = "Base64-encoded SHA256 hash of the package file (Zip package type)."
}

variable "s3_bucket" {
  type        = string
  default     = null
  description = "S3 bucket containing the function zip (Zip package type)."
}

variable "s3_key" {
  type        = string
  default     = null
  description = "S3 key of the function zip (Zip package type)."
}

variable "image_uri" {
  type        = string
  default     = null
  description = "ECR image URI (Image package type)."
}

# Environment and secrets
variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables for the Lambda function."
}

variable "secrets_names" {
  type        = map(string)
  default     = {}
  description = "Map of secret names in AWS Secrets Manager to grant access to."
}

# VPC configuration
variable "vpc_subnet_ids" {
  type        = list(string)
  default     = null
  description = "List of subnet IDs for VPC-attached Lambda. If null, Lambda runs outside VPC."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs for VPC-attached Lambda."
}

# IAM
variable "custom_policy_statements" {
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default     = []
  description = "Additional custom policy statements for the Lambda role."
}

variable "linked_policies" {
  description = "Additional policy ARNs to attach to the Lambda role"
  type        = map(string)
  default     = {}
}

# Advanced
variable "reserved_concurrent_executions" {
  type        = number
  default     = -1
  description = "Amount of reserved concurrent executions. -1 means unreserved."
}

variable "publish" {
  type        = bool
  default     = false
  description = "Whether to publish creation/change as a new Lambda version."
}

variable "layers" {
  type        = list(string)
  default     = []
  description = "List of Lambda Layer ARNs to attach."
}

variable "dead_letter_target_arn" {
  type        = string
  default     = null
  description = "ARN of an SNS topic or SQS queue for the dead letter queue."
}

variable "log_retention_in_days" {
  type        = number
  default     = 14
  description = "CloudWatch log group retention in days."
}

# EventBridge
variable "eventbridge_rules" {
  type = map(object({
    description         = optional(string, "")
    schedule_expression = optional(string, null)
    event_pattern       = optional(string, null)
    is_enabled          = optional(bool, true)
    input               = optional(string, null)
    input_path          = optional(string, null)
  }))
  default     = {}
  description = "Map of EventBridge rules to create and associate with this Lambda. Each rule needs either schedule_expression or event_pattern."
}
