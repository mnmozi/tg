variable "cache_policies" {
  description = "List of cache policies to create"
  type = list(object({
    name                          = string
    comment                       = string
    default_ttl                   = number
    max_ttl                       = number
    min_ttl                       = number
    enable_accept_encoding_brotli = optional(bool, true)
    enable_accept_encoding_gzip   = optional(bool, true)
    cookies_config = object({
      cookie_behavior = string
    })
    headers_config = object({
      header_behavior = string
      headers         = optional(list(string), [])
    })
    query_strings_config = object({
      query_string_behavior = string
      query_strings         = optional(list(string), [])
    })
  }))
}

variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}
