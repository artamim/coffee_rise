output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website.bucket
}

output "website_endpoint" {
  description = "The website endpoint URL (HTTP)"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_domain" {
  description = "The full website domain (for CloudFront origin)"
  value       = aws_s3_bucket_website_configuration.website.website_domain
}