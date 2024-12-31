terraform {
  source = "${path_relative_from_include()}/../../../modules/ecs/01-task-definition"
}
include "root" {
  path   = find_in_parent_folders()
  expose = true
}


inputs = {
  images_repos    = ["yozo-sidekiq"]
  container_names = ["yozo-sidekiq"]
  cpus = {
    yozo-sidekiq = 256
  }

  memories = {
    yozo-sidekiq = 512
  }
  # containers_port = { yozo-application = 80 }
  # hosts_port      = { yozo-application = 80 }
  # commands = { yozo-application = [
  #   "bin/rails db:migrate && exec bundle exec rails s -b '0.0.0.0'"
  # ] }

  required_tags = {
    project   = "yozo"
    component = "sidekiq"
  }

  tags = {}
  # environment_variables = {
  #   yozo-application = [
  #     { name = "AWS_REGION", value = "eu-central-1" },
  #     { name = "AWS_BUCKET", value = "prod-yozo-images" },
  #     { name = "HOST", value = "https://scribe.cortechs-ai.com" },
  #     { name = "RAILS_ENV", value = "production" }
  #   ]
  # }
  secrets_names = {
    yozo-sidekiq = "staging-yozo"
  }
  # secrets = {
  #   yozo-application = [
  #     "SHOPIFY_API_KEY", 
  #     "SHOPIFY_API_SECRET", 
  #     "OPENAI_ACCESS_KEY", 
  #     "POSTGRES_HOST", 
  #     "POSTGRES_DB", 
  #     "POSTGRES_USER",
  #     "POSTGRES_PASSWORD",
  #     "SECRET_KEY_BASE",
  #     "RAILS_SERVE_STATIC_FILES",
  #     "REDIS_URL",
  #     "PORT",
  #     "GOOGLE_ADS_DEVELOPER_TOKEN",
  #     "GOOGLE_ADS_CLIENT_ID",
  #     "GOOGLE_ADS_CLIENT_SECRET",
  #     "GOOGLE_ADS_REFRESH",

  #     ]
  # }
  custom_execution_statements = [
    {
      Effect = "Allow",
      Action = [
        "ssm:DescribeInstanceInformation",
        "ssm:SendCommand",
        "ssm:StartSession",
        "ssm:DescribeSessions",
        "ssm:GetConnectionStatus",
        "ssm:DescribeInstanceProperties",
        "ssmmessages:*",
        "ec2messages:*"
      ],
      Resource = ["*"]
    }
  ]
  log_drivers = {
    yozo-sidekiq = "awslogs"
  }
  requires_compatibilities = ["FARGATE"]
  cpu_architecture         = "X86_64"
}
