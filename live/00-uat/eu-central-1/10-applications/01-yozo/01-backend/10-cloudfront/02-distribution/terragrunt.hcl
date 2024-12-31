terraform {
  source = "${path_relative_from_include()}/../../../modules/cloudfront/distribution"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "lb" {
  config_path = "${path_relative_from_include()}/10-applications/00-common/lbs/01-external-lb/01-lb"
}

dependency "caching_policy" {
  config_path = "../01-cache-policy"
}

inputs = {
  required_tags = {
    project   = "yozo"
    component = "application"
  }

  aliases = ["staging-yozo.cortechs-ai.com"]

  origin_config = [
    {
      domain_name          = dependency.lb.outputs.alb.dns_name
      origin_id            = dependency.lb.outputs.alb.name
      connection_attempts  = 3
      connection_timeout   = 10
      http_port            = 80
      https_port           = 443
      origin_ssl_protocols = ["TLSv1.2"]
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "https-only"
        origin_read_timeout      = 30
        origin_ssl_protocols = [
          "TLSv1.2",
        ]
      }
      custom_headers = [
        { name = "X-Forwarded-Proto", value = "https" },
        { name = "X-Forwarded-Ssl", value = "on" },
        { name = "Random-Salt", value = "XKy5LLll87NNiRYurq" }
      ]
    },
    {
      connection_attempts      = 3
      connection_timeout       = 10
      domain_name              = "staging-yozo-images.s3.eu-central-1.amazonaws.com"
      origin_access_control_id = "E2K3J056WO3QQL"
      origin_id                = "staging-yozo-images.s3.eu-central-1.amazonaws.com"
    }
  ]

  # default_cache_behavior = {
  #   target_origin_id         = dependency.lb.outputs.alb.name
  #   allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods           = ["GET", "HEAD"]
  #   compress                 = true
  #   viewer_protocol_policy   = "redirect-to-https"
  #   cache_policy_id          = dependency.caching_policy.outputs.cache_policy_ids[0]
  #   origin_request_policy_id = "Managed-AllViewer"
  # }

  ordered_cache_behaviors = {
    default = {
      path_pattern             = ""
      target_origin_id         = dependency.lb.outputs.alb.name
      allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods           = ["GET", "HEAD"]
      compress                 = true
      viewer_protocol_policy   = "redirect-to-https"
      origin_request_policy_id = "Managed-AllViewer"
    },
    "images" = {
      path_pattern           = "/images/*"
      target_origin_id       = "staging-yozo-images.s3.eu-central-1.amazonaws.com"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
  }

  cache_policy_ids = {
    default = dependency.caching_policy.outputs.cache_policy_ids[0].name
    images  = "Managed-CachingOptimized"
  }

  origin_request_policy_ids = {
    default = "Managed-AllViewer",
    images  = "Managed-AllViewer"
  }

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:613725395756:certificate/9e9919ae-8b7d-4dae-b970-4e7dd8713f79"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
