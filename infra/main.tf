terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "web_app_1" {
  source = "./modules/s3"

  bucket_name = "coffee-rise-website-2026"
  environment = "prod"
}