variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster. If not provided, will be auto-generated from environment and tags"
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API server"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the EKS API server"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable creator admin permissions for the cluster"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster (worker nodes)"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "List of subnet IDs for the EKS control plane. If not provided, subnet_ids will be used"
  type        = list(string)
  default     = []
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

variable "cluster_addons" {
  description = "Map of EKS cluster addons to install"
  type        = any
  default = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
}

variable "cluster_compute_config" {
  description = "Configuration for EKS Auto Mode compute config"
  type = object({
    enabled    = bool
    node_pools = optional(list(string), ["general-purpose"])
  })
  default = null
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions"
  type        = any
  default     = {}
}

variable "self_managed_node_groups" {
  description = "Map of self-managed node group definitions"
  type        = any
  default     = {}
}

variable "fargate_profiles" {
  description = "Map of Fargate profile definitions"
  type        = any
  default     = {}
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "cluster_enabled_log_types" {
  description = "List of control plane logging to enable"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "node_security_group_additional_rules" {
  description = "Additional rules to add to the node security group"
  type        = any
  default     = {}
}

variable "cluster_security_group_additional_rules" {
  description = "Additional rules to add to the cluster security group"
  type        = any
  default     = {}
}

variable "create_kms_key" {
  description = "Controls if a KMS key for cluster encryption should be created"
  type        = bool
  default     = true
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type        = any
  default = {
    resources = ["secrets"]
  }
}

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are CONFIG_MAP, API or API_AND_CONFIG_MAP"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}
