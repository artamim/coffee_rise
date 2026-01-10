output "counter_table_name" {
  value = aws_dynamodb_table.visitor_counter.name
}

output "counter_table_arn" {
  value = aws_dynamodb_table.visitor_counter.arn
}

output "logs_table_name" {
  value = aws_dynamodb_table.visitor_logs.name
}

output "logs_table_arn" {
  value = aws_dynamodb_table.visitor_logs.arn
}