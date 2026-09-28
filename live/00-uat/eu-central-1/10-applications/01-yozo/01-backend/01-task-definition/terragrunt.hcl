terraform {
  source = "${get_repo_root()}/modules//ecs/01-task-definition"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  images_repos    = ["yozo-application"]
  container_names = ["yozo-application"]

  cpus     = { yozo-application = 256 }
  memories = { yozo-application = 512 }

  containers_port = { yozo-application = 80 }
  hosts_port      = { yozo-application = 80 }

  required_tags = {
    project   = "yozo"
    component = "application"
  }

  tags = {}

  # All runtime configuration comes from this Secrets Manager secret; every key
  # in it is injected as a container secret.
  secrets_names = {
    yozo-application = "staging-yozo"
  }

  log_drivers = {
    yozo-application = "awslogs"
  }

  # Execution role: pulling images/secrets is covered by the module; only the
  # image bucket is app specific.
  custom_execution_statements = [
    {
      Effect   = "Allow",
      Action   = ["s3:PutObject", "s3:GetObject"],
      Resource = ["arn:aws:s3:::staging-yozo-images/*"],
    }
  ]

  # Task role: what the running app may do (ECS Exec permissions are added by the module).
  custom_task_role_statements = [
    {
      Effect   = "Allow",
      Action   = ["s3:PutObject"],
      Resource = ["arn:aws:s3:::staging-yozo-images/*"],
    }
  ]

  requires_compatibilities = ["FARGATE"]
  cpu_architecture         = "X86_64"
}
