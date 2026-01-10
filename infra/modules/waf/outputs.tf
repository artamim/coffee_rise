output "web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with CloudFront"
  value       = aws_wafv2_web_acl.cloudfront_waf.arn
}