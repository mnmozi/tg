resource "aws_cloudfront_cache_policy" "policies" {
  for_each = { for idx, policy in var.cache_policies : idx => policy }

  name        = each.value.name
  comment     = each.value.comment
  default_ttl = each.value.default_ttl
  max_ttl     = each.value.max_ttl
  min_ttl     = each.value.min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = each.value.cookies_config.cookie_behavior
    }

    headers_config {
      header_behavior = each.value.headers_config.header_behavior

      headers {
        items = each.value.headers_config.headers != null ? toset(each.value.headers_config.headers) : []
      }
    }

    query_strings_config {
      query_string_behavior = each.value.query_strings_config.query_string_behavior

      query_strings {
        items = each.value.query_strings_config.query_strings != null ? toset(each.value.query_strings_config.query_strings) : []
      }
    }
  }
}
