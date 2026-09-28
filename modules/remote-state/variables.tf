variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, production)"
  type        = string
}

variable "required_tags" {
  description = "Required tags for resources"
  type        = map(string)
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = null
}

variable "enable_replication" {
  description = "if you want to enable dynamo-db replication"
  type        = bool
  default     = false
}

variable "dynamodb_table_name" {
  description = "name of the dynamodb table"
  type        = string
  default     = "terraform_locking_table"
}
variable "s3_bucket_name" {
  description = "name of the s3 bucket"
  type        = string
}
