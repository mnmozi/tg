variable "zone_name" {
  description = "Name of the Route 53 zone"
  type        = string
}

variable "private_zone" {
  description = "Whether the Route 53 zone is private"
  type        = bool
  default     = false
}

variable "records" {
  description = <<EOT
An array of objects defining the Route 53 records to create. Each object supports:
- name: The name of the record (e.g., "www").
- type: The type of the record (e.g., "A", "CNAME").
- ttl: (Optional) The TTL for the record.
- weight: (Optional) The weight for weighted routing.
- set_identifier: (Optional) Identifier for weighted routing.
- records: (Optional) The records (e.g., IP addresses or CNAMEs) for the record.
- alias: (Optional) An object defining alias properties:
  - name: Alias target DNS name.
  - zone_id: Route 53 zone ID of the target.
  - evaluate_target_health: (Optional) Whether to evaluate target health.
EOT
  type = list(object({
    name           = string
    type           = string
    ttl            = optional(number)
    weight         = optional(number)
    set_identifier = optional(string)
    records        = optional(list(string))
    alias = optional(object({
      name = string
      # zone_id                = string
      evaluate_target_health = optional(bool)
    }))
  }))
  default = []
}
