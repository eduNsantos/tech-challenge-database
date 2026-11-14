terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "techchallenge-tfstate-477478162709-v2"
    key          = "database/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
