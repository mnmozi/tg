variable "name" {
  type        = string
  description = "The name of the IAM role and instance profile."
}

variable "policies" {
  type        = map(string)
  description = "A map of policy ARNs to attach to the IAM role."
}

variable "principal_service" {
  type        = list(string)
  description = "A list of AWS services that can assume the IAM role (e.g., 'ec2.amazonaws.com')."
}

variable "is_instance" {
  type        = bool
  default     = true
  description = "Whether to create an instance profile for the IAM role."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to assign to all resources created by this module."
}
