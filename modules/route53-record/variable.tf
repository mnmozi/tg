variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "zone_id" {
  description = "Name of the Route 53 zone"
  type        = string
}

# variable "zone_name" {
#   description = "Name of the Route 53 zone"
#   type        = string
# }

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

