variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "environment" {
  description = "Environment tag (e.g., prod, dev)"
  type        = string
  default     = "prod"
}