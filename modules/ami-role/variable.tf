variable "name" {
  type        = string
  description = "The name of the IAM role and associated instance profile."
}

variable "policies" {
  type        = map(string)
  description = "A map of policy ARNs to attach to the IAM role. Example: { 'policy1': 'arn:aws:iam::aws:policy/AmazonS3FullAccess' }"
}

variable "principal_service" {
  type        = list(string)
  description = "A list of AWS services allowed to assume this IAM role (e.g., ['ec2.amazonaws.com'])."
}

variable "is_instance" {
  type        = bool
  default     = true
  description = "Whether to create an instance profile for the IAM role."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to assign to all resources created by this module. Example: { 'Environment': 'dev', 'Owner': 'admin' }"
}
