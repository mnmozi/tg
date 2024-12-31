variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "The environment for the resources (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster. Defaults to a combination of environment, project, and component if not provided"
  type        = string
  default     = null
}

variable "required_tags" {
  description = "Required tags for the resources"
  type        = map(string)
  default = {
    project   = "my-project"
    component = "redis"
  }
}

variable "tags" {
  description = "Additional tags for the resources"
  type        = map(string)
  default     = {}
}

variable "owner" {
  description = "The owner of the resources"
  type        = string
  default     = null
}

variable "secret_name" {
  description = "The name of the Secrets Manager secret"
  type        = string
}

variable "secret_key" {
  description = "The key inside the secret that holds the auth token"
  type        = string
}

variable "automatic_failover_enabled" {
  description = "Whether automatic failover is enabled for the replication group"
  type        = bool
  default     = true
}

variable "node_type" {
  description = "The instance class for the Redis nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "engine" {
  description = "The Redis engine to use"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "The version of the Redis engine"
  type        = string
  default     = "6.x"
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately or during the next maintenance window"
  type        = bool
  default     = true
}

variable "num_node_groups" {
  description = "The number of node groups (shards) in the replication group"
  type        = number
  default     = 1
}

variable "port" {
  description = "The port on which the Redis service is available"
  type        = number
  default     = 6379
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the replication group"
  type        = list(string)
  default     = []
}

variable "transit_encryption_enabled" {
  description = "Whether to enable in-transit encryption for the replication group"
  type        = bool
  default     = true
}

variable "subnet_group_name" {
  description = "The name of the ElastiCache subnet group to associate with the replication group"
  type        = string
  default     = null
}
