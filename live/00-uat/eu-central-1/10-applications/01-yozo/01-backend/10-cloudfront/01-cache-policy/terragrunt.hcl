terraform {
  source = "${path_relative_from_include()}/../../../modules/cloudfront/cache-policy"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}


inputs = {
  cache_policies = [
    {
      name        = "staging-origin-caching"
      comment     = "This cache policy is controlled by the header of the origin"
      default_ttl = 0
      max_ttl     = 31536000
      min_ttl     = 0
      cookies_config = {
        cookie_behavior = "none"
      }
      headers_config = {
        header_behavior = "whitelist"
        headers         = ["Cache-Control"]
      }
      query_strings_config = {
        query_string_behavior = "none"
        query_strings         = []
      }
    }
  ]
}
