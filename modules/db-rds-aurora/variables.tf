variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "environment" {
  type        = string
  description = "Environment name (dev, uat, prod)."
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
  description = "Required tags for the cluster: project and component."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to include for the cluster."
}

variable "db_name" {
  type        = string
  default     = null
  description = "Cluster identifier. Defaults to <environment>-<instance_class>-<project>-<component>."
}

# ---------------------------------------------------------------------------
# Engine / instances
# ---------------------------------------------------------------------------
variable "engine" {
  type        = string
  default     = "aurora-postgresql"
  description = "Aurora engine (aurora-postgresql or aurora-mysql)."
}

variable "engine_version" {
  type        = string
  description = "Engine version."
}

variable "instance_class" {
  type        = string
  description = "Instance class applied to every cluster instance (e.g. db.t4g.medium)."
}

variable "instances" {
  type        = map(any)
  description = "Map of cluster instances. Values may override any per-instance attribute (instance_class, publicly_accessible, promotion_tier, ...)."
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Default publicly_accessible for every instance (override per instance in `instances`)."
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Default Performance Insights setting for every instance (override per instance in `instances`)."
}

variable "cluster_performance_insights_retention_period" {
  type        = number
  default     = null
  description = "Cluster-level Performance Insights retention in days (7, 731, or a multiple of 31)."
}

variable "port" {
  type        = number
  description = "Port the cluster listens on."
}

# ---------------------------------------------------------------------------
# Parameter groups
# ---------------------------------------------------------------------------
variable "create_db_parameter_group" {
  type        = bool
  default     = false
  description = "Create a cluster parameter group and a DB parameter group from the families below."
}

variable "db_cluster_parameter_group_family" {
  type        = string
  default     = ""
  description = "Cluster parameter group family (e.g. aurora-postgresql16)."
}

variable "db_parameter_group_family" {
  type        = string
  default     = ""
  description = "DB (instance) parameter group family (e.g. aurora-postgresql16)."
}

variable "parameter_group_name" {
  type        = string
  default     = null
  description = "Existing cluster parameter group to use when create_db_parameter_group is false."
}

# ---------------------------------------------------------------------------
# Credentials
# ---------------------------------------------------------------------------
variable "username" {
  type        = string
  default     = "master_user"
  description = "Master username."
}

variable "manage_master_user_password" {
  type        = bool
  default     = false
  description = "Let RDS create and rotate the master password in Secrets Manager. When true, secret_name/password_key/password are ignored."
}

variable "secret_name" {
  type        = string
  default     = null
  description = "Secrets Manager secret holding the master password."
}

variable "password_key" {
  type        = string
  default     = null
  description = "JSON key inside `secret_name` that holds the password."
}

variable "password_version" {
  type        = number
  default     = 1
  description = "Increment after rotating the password in Secrets Manager; the master password is write-only and only re-sent when this changes."
}

variable "password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Plain-text fallback. Not recommended: prefer secret_name + password_key or manage_master_user_password."
}

# ---------------------------------------------------------------------------
# Storage / backups
# ---------------------------------------------------------------------------
variable "allocated_storage" {
  type        = number
  default     = null
  description = "Allocated storage in GB (only for provisioned io-optimized/limitless setups)."
}

variable "storage_type" {
  type        = string
  default     = null
  description = "Storage type (aurora, aurora-iopt1)."
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Encrypt storage at rest."
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Apply changes immediately instead of during the maintenance window."
}

variable "from_backup" {
  type        = bool
  default     = false
  description = "Restore from the most recent manual cluster snapshot of `snapshot_identifier` (defaults to this cluster's identifier)."
}

variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "Cluster identifier whose most recent manual snapshot is restored when from_backup is true."
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Skip the final snapshot on destroy."
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Name of the final snapshot. Defaults to <cluster identifier>-final."
}

variable "delete_automated_backups" {
  type        = bool
  default     = true
  description = "Remove automated backups immediately after the cluster is deleted."
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Days to retain automated backups."
}

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  description = "Copy cluster tags to snapshots."
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection on the cluster."
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable IAM database authentication."
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups attached to the cluster."
}

variable "db_subnet_group_name" {
  type        = string
  description = "Existing DB subnet group name."
}
