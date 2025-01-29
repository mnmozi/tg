#------------------------------------------------------------------------------
# VPC variables
#------------------------------------------------------------------------------

variable "region" {
  type        = string
  description = "The region to deploy the resoruces in"
}

variable "az_count" {
  description = "Number of Availability Zones to use (1, 2, or 3)"
  type        = number
  default     = 3
}

variable "create_database_subnet" {
  description = "Flag to determine if database subnets should be created"
  type        = bool
  default     = false
}

variable "create_elasticache_subnet" {
  description = "Flag to determine if Elasticache subnets should be created"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnets provided by the user. Leave empty if auto-generation is required."
  type        = list(string)
  default     = [] # Default to an empty list if not provided
}
variable "private_subnet_tags" {
  type    = map(string)
  default = {}
}
variable "public_subnet_tags" {
  type    = map(string)
  default = {}
}
variable "public_subnet_tags_per_az" {
  type        = map(map(string)) # Nested map to hold tags for each AZ
  description = "Public subnet tags per AZ, keyed by 1, 2, 3"
  default     = {} # Add default tags if needed
}
variable "private_subnet_tags_per_az" {
  type        = map(map(string)) # Nested map to hold tags for each AZ
  description = "private subnet tags per AZ, keyed by 1, 2, 3"
  default     = {} # Add default tags if needed
}
variable "subnets_per_az" {
  description = "Number of subnets per AZ for private, public, database, and Elasticache"
  type        = map(number)
  default = {
    private     = 1
    public      = 1
    database    = 0
    elasticache = 0
  }
}


variable "environment" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "owner" {
  type    = string
  default = null
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "cidr" {
  description = "This VPC cidr."
  type        = string
  default     = "10.1.0.0/16"
}


variable "subnet_sizes" {
  type        = list(number)
  description = "A list of numbers representing subnet sizes"
  default     = [2, 2, 2, 6, 6, 6, 8, 8, 8, 8, 8, 8]
}


variable "required_tags" {
  type = object({
    environment = string
    project     = string
    component   = string
    critical    = string
  })
  description = "Required tags for all resources, including environment, project, component, and criticality."
}

variable "tags" {
  description = "Extra tags for the VPC resources"
  type        = map(any)
}

variable "create_public_db_subnet_group" {
  description = "Control if to create a public subnet group for db or no"
  type        = bool
  default     = false
}

variable "create_private_elasticache_subnet_group" {
  description = "Control if to create a private subnet group for elasticache or no"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks	"
  type        = bool
  default     = false
}

variable "private_hosted_zone" {
  description = "Should be true if you want to provision private hosted zone"
  type        = bool
  default     = false
}
