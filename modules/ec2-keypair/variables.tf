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

variable "public_key" {
  description = "The public key material in OpenSSH format (e.g. contents of an id_rsa.pub / id_ed25519.pub file)"
  type        = string
}

variable "key_name" {
  description = "Optional override for the key pair name. If null, the module-generated identifier is used."
  type        = string
  default     = null
}
