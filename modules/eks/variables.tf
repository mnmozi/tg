variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API server"
  type        = bool
  default     = false
}

variable "enable_efa_support" {
  description = "Enable Elastic Fabric Adapter (EFA) support for the EKS cluster"
  type        = bool
  default     = false
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA) in the EKS cluster"
  type        = bool
  default     = true
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
  description = "List of subnet IDs"
  type        = list(string)
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
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "cluster_compute_config" {
  description = "Configuration for cluster compute config"
  type = object({
    enabled    = bool
    node_pools = list(string)
  })
  default = {
    enabled    = true
    node_pools = ["general-purpose"]
  }
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node groups"
  type = map(object({
    ami_type       = string
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = list(string)
    capacity_type  = string
    labels         = map(string)
    tags           = map(string)
  }))
  default = {
    general-purpose = {
      ami_type       = ""
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels = {
        role = "general"
      }
      tags = {
        Name = "general-node"
      }
    }
  }
}

variable "cluster_addons" {
  description = "Map of EKS cluster addons to install"
  type        = map(any)
  default = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
}
