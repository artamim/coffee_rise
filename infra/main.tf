locals {
  environment = "prod"
}

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

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

module "web_app_1" {
  source      = "./modules/s3"
  bucket_name = "coffee-rise-website-2026"
  environment = local.environment
}

module "waf" {
  source = "./modules/waf"

  providers = {
    aws = aws.useast1
  }

  bucket_id   = module.web_app_1.bucket_id
  environment = local.environment
  # Remove depends_on – not needed and was causing issues
}

module "cloudfront" {
  source                      = "./modules/cloudfront"
  bucket_regional_domain_name = module.web_app_1.bucket_regional_domain_name
  bucket_id                   = module.web_app_1.bucket_id
  environment                 = local.environment
  web_acl_arn                 = module.waf.web_acl_arn

  depends_on = [module.web_app_1, module.waf]  # Keeps explicit order
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  environment = local.environment
}

module "tracking" {
  source             = "./modules/tracking"
  environment        = local.environment
  counter_table_name = module.dynamodb.counter_table_name
  logs_table_name    = module.dynamodb.logs_table_name

  depends_on = [module.dynamodb]
}