variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "environment" {
  type        = string
  description = "The AWS region to deploy the resources in."
}

variable "owner" {
  type    = string
  default = null
}

variable "required_tags" {
  description = "Required tags for resources"
  type        = map(string)
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to include for the RDS instance."
}

variable "cache_policy_name" {
  description = "Name of the CloudFront cache policy to use"
  type        = string
  default     = "Managed-CachingDisabled"
}

variable "origin_request_policy_name" {
  description = "Name of the CloudFront origin request policy to use"
  type        = string
  default     = "Managed-AllViewer"
}

variable "aliases" {
  description = "Aliases for the CloudFront distribution"
  type        = list(string)
  default     = []
}
variable "origin_config" {
  description = "List of origins for the CloudFront distribution"
  type = list(object({
    domain_name              = string
    origin_id                = string
    connection_attempts      = number
    connection_timeout       = number
    origin_access_control_id = optional(string, null)
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    custom_origin_config = optional(object({
      http_port              = optional(number, 80)
      https_port             = optional(number, 443)
      origin_protocol_policy = string

      origin_ssl_protocols = list(string)
    }), null)
    vpc_origin_config = optional(object({
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
      vpc_origin_id            = string
    }), null)
  }))
}


variable "cache_policy_ids" {
  type = map(string)
}

variable "origin_request_policy_ids" {
  type = map(string)
}

variable "ordered_cache_behaviors" {
  type = map(object({
    path_pattern           = string
    target_origin_id       = string
    allowed_methods        = list(string)
    cached_methods         = list(string)
    compress               = bool
    viewer_protocol_policy = string
  }))
  default = {
    "default" = {
      path_pattern           = ""
      target_origin_id       = "default-origin-id"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
  }
}

variable "cache_policy_names" {
  type = map(string)
  default = {
    "default" = "CachingDisabled"
  }
}

variable "origin_request_policy_names" {
  type = map(string)
  default = {
    "default" = "Managed-AllViewer"
  }
}



# variable "default_cache_behavior" {
#   description = "Default cache behavior for the CloudFront distribution"
#   type = object({
#     target_origin_id         = string
#     allowed_methods          = list(string)
#     cached_methods           = list(string)
#     compress                 = bool
#     viewer_protocol_policy   = string
#     cache_policy_id          = string
#     origin_request_policy_id = string
#   })
# }

variable "viewer_certificate" {
  description = "Viewer certificate configuration"
  type = object({
    acm_certificate_arn      = optional(string, null)
    ssl_support_method       = string
    minimum_protocol_version = string
    acm_domain = optional(object({
      domain      = string
      types       = optional(list(string), ["AMAZON_ISSUED"])
      statuses    = optional(list(string), ["ISSUED"])
      most_recent = optional(bool, true)
    }), null)
  })
}
