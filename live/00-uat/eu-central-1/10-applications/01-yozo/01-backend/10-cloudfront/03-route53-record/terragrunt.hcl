terraform {
  source = "${get_repo_root()}/modules//route53-record"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "cloudfront" {
  config_path = "../02-distribution"
}

inputs = {
  zone_name    = "cortechs-ai.com"
  private_zone = false

  record = {
    name = "staging-yozo.cortechs-ai.com"
    type = "A"
    alias = {
      name                   = dependency.cloudfront.outputs.cloudfront_distribution_domain_name
      zone_id                = dependency.cloudfront.outputs.cloudfront_distribution_hosted_zone
      evaluate_target_health = true
    }
  }
}
