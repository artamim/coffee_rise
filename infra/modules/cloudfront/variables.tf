variable "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  type        = string
}

variable "bucket_id" {
  description = "S3 bucket ID"
  type        = string
}

variable "environment" {
  type = string
}

variable "web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate"
  type        = string
  default     = null  # Optional – allows disabling WAF if needed
}