# Generate the provider configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81"
    }
  }
}

provider "aws" {
  region = var.region
}
