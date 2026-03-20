variable "region" {
  type = string
}

variable "environment" {
  type = string
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
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "bucket_name" {
  type    = string
  default = null
}

variable "versioning" {
  type    = bool
  default = false
}

variable "noncurrent_version_keep_count" {
  type        = number
  default     = null
  description = "Number of noncurrent versions to keep. If set, older noncurrent versions will be deleted."
}
