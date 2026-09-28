terraform {
  source = "${get_repo_root()}/modules//ecs/00-ecr"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
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
    component = "component-name"
  }
  scan_on_push = false
}