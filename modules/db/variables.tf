variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "environment" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "snapshot_identifier" {
  type        = string
  description = "snap-shot identifier"
  default     = ""
}

variable "owner" {
  type    = string
  default = null
}
variable "db_name" {
  type = string

  default = null
}

# Naming variables
variable "required_tags" {
  type = object({
    project   = string
    component = string
  })
  description = "Required tags for the RDS instance, including application and component."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to include for the RDS instance."
}

# RDS settings
variable "instance_access_type" {
  type        = string
  default     = "private"
  description = "The type and scope of the instance (e.g., public, private)."
}

variable "secret_name" {
  type        = string
  description = "The name of the secret in AWS Secrets Manager containing the database credentials."
}
variable "password" {
  type        = string
  description = "THIS IS NOT RECOMENDED, PLEASE CONSEDER CREATING SECRET AND PASS IT IN secret_name and  password_key."
}

variable "password_key" {
  type        = string
  description = "The key for the password in the AWS Secrets Manager secret."
}

variable "engine" {
  type        = string
  default     = "postgres"
  description = "The database engine to use (e.g., mysql, postgres)."
}

variable "engine_version" {
  type        = string
  description = "The version of the database engine to use."
}

variable "family" {
  type        = string
  description = "The family of the database parameter group."
}

variable "instance_class" {
  type        = string
  description = "The instance class for the RDS database (e.g., db.t3.micro)."
}

variable "create_db_parameter_group" {
  type        = bool
  default     = false
  description = "Whether to create a new DB parameter group."
}

variable "parameter_group_name" {
  type        = string
  description = "The name of the DB parameter group to associate with the RDS instance."
}

variable "allocated_storage" {
  type        = number
  default     = 15
  description = "The allocated storage size in GB for the RDS instance."
}

variable "max_allocated_storage" {
  type        = number
  default     = 0
  description = "The allocated storage size in GB for the RDS instance."
}

variable "username" {
  type        = string
  default     = "master_user"
  description = "The master username for the RDS database."
}

variable "storage_type" {
  type        = string
  default     = "gp3"
  description = "The type of storage to use for the RDS database (e.g., gp2, io1)."
}

variable "port" {
  type        = number
  description = "The port on which the RDS instance will accept connections."
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Whether to deploy the RDS instance in multiple availability zones."
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Whether to enable storage encryption for the RDS instance."
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Whether to apply changes immediately or during the next maintenance window."
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Whether to skip taking a final snapshot before deleting the RDS instance."
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable performance insights for the RDS instance."
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable IAM authentication for the RDS instance."
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Whether the RDS instance should be publicly accessible."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to associate with the RDS instance."
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the DB subnet group to associate with the RDS instance."
}

variable "from_backup" {
  type        = bool
  default     = false
  description = "Whether to copy tags to snapshots."
}

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  description = "Whether to copy tags to snapshots."
}

