output "tracking_api_url" {
  description = "URL to call for tracking visits"
  value       = "${aws_apigatewayv2_api.tracking_api.api_endpoint}/track"
}