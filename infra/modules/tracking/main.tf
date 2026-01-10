data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "tracking-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "tracking-lambda-dynamodb-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:PutItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.counter_table_name}",
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.logs_table_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "tracker" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "visitor-tracker-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      COUNTER_TABLE = var.counter_table_name
      LOGS_TABLE    = var.logs_table_name
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_api" "tracking_api" {
  name          = "tracking-api-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.tracking_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.tracker.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "track_route" {
  api_id    = aws_apigatewayv2_api.tracking_api.id
  route_key = "GET /track"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.tracking_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tracker.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.tracking_api.execution_arn}/*"
}