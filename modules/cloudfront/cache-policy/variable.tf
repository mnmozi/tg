variable "cache_policies" {
  description = "List of cache policies to create"
  type = list(object({
    name        = string
    comment     = string
    default_ttl = number
    max_ttl     = number
    min_ttl     = number
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
