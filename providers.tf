terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    bucket         = "techchallenge-tfstate"
    key            = "database/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "techchallenge-tf-locks"
    encrypt        = true
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
