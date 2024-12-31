output "cache_policy_ids" {
  description = "Map of cache policy names to their IDs"
  value = {
    for idx, policy in aws_cloudfront_cache_policy.policies :
    idx => {
      name = policy.name
      id   = policy.id
    }
  }
}
