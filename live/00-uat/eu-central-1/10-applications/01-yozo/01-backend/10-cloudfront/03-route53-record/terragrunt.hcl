terraform {
  source = "${path_relative_from_include()}/../../../modules/route53-record"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "cloudfront" {
  config_path = "../02-distribution"
}

inputs = {
  zone_name    = "cortechs-ai.com"
  private_zone = false

  records = [
    {
      name = "sstaging-yozo.cortechs-ai.com"
      type = "A"
      alias = {
        name                   = dependency.cloudfront.outputs.cloudfront_distribution_domain_name
        zone_id                = dependency.cloudfront.outputs.hosted_zone_id
        evaluate_target_health = true
      }
    }
  ]
}