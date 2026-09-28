terraform {
  source = "${get_repo_root()}/modules//ecs/01-task-definition"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  images_repos    = ["yozo-sidekiq"]
  container_names = ["yozo-sidekiq"]

  cpus     = { yozo-sidekiq = 256 }
  memories = { yozo-sidekiq = 512 }

  required_tags = {
    project   = "yozo"
    component = "sidekiq"
  }

  tags = {}

  secrets_names = {
    yozo-sidekiq = "staging-yozo"
  }

  log_drivers = {
    yozo-sidekiq = "awslogs"
  }

  requires_compatibilities = ["FARGATE"]
  cpu_architecture         = "X86_64"
}
