# Generate the provider configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.27.0"
    }
  }
}

provider "aws" {
  region = var.region
}
