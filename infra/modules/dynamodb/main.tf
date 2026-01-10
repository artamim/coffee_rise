resource "aws_dynamodb_table" "visitor_counter" {
  name           = "VisitorCounter"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Purpose     = "Total visit counter - indefinite retention"
  }
}

resource "aws_dynamodb_table" "visitor_logs" {
  name           = "VisitorLogs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Environment = var.environment
    Purpose     = "Detailed visit logs"
  }
}