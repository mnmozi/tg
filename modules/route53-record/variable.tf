variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "zone_id" {
  description = "ID of the Route 53 zone. If not provided, zone_name will be used to look it up."
  type        = string
  default     = null
}

variable "zone_name" {
  description = "Name of the Route 53 zone. Used to look up zone_id if zone_id is not provided."
  type        = string
  default     = null
}

variable "private_zone" {
  description = "Whether the Route 53 zone is private"
  type        = bool
  default     = false
}
variable "record" {
  type = object({
    name   = string
    type   = string
    ttl    = optional(number)
    weight = optional(number)
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }))
    records        = optional(list(string))
    set_identifier = optional(string)
  })
}

