terraform {
  source = "../../../../../modules/ecs/00-ecr"
}

include "environment" {
  path   = find_in_parent_folders("environment.hcl")
  expose = true
}

inputs = {
  max_image_count = 30
  protected_tags_and_number = {
    "prod"    = 10
    "staging" = 5
    "testing" = 3
  }
  tags = {}
  required_tags = {
    project   = "project-name"
    component = "componen-name"
  }
  scan_on_push = false
}