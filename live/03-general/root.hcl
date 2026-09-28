# Define local variables
locals {
  region      = "<region>"
  environment = "<env>"
  s3_bucket   = "<s3-bucket>"
  kms_key_id  = "<kms-key>"
}

# Configure the remote state backend
remote_state {
  backend = "s3"
  config = {
    bucket         = local.s3_bucket
    key            = "${local.environment}/${local.region}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    kms_key_id     = local.kms_key_id
    dynamodb_table = "terraform_locking_table"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "skip" # Do not overwrite if the file already exists
  }
}


inputs = {
  tags = {
    environment = local.environment
    owner       = "Random-Salt"
  }
  environment = local.environment
  region      = local.region
}
