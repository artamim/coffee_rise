terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

resource "aws_wafv2_web_acl" "cloudfront_waf" {
  provider = aws.useast1

  name        = "waf-${var.bucket_id}-${var.environment}"
  description = "WAF for CloudFront distribution - ${var.environment}"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Core Rule Set - common web exploits (OWASP Top 10)
  rule {
    name     = "AWS-CoreRuleSet"
    priority = 10

    override_action {
      none {} # Use managed rules as-is (change to count {} for monitoring only)
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-CoreRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # IP Reputation List - blocks known malicious IPs
  rule {
    name     = "AWS-IPReputation"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-IPReputation"
      sampled_requests_enabled   = true
    }
  }

  # Known Bad Inputs
  rule {
    name     = "AWS-KnownBadInputs"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # Rate-based rule - block abusive IPs (adjust limit as needed)
  rule {
    name     = "RateLimit"
    priority = 40

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000 # requests per 5 minutes per IP
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfront-waf-acl"
    sampled_requests_enabled   = true
  }

  tags = {
    Environment = var.environment
  }
}