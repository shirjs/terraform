resource "aws_apigatewayv2_api" "api" {
  name = var.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = var.allowed_headers
    allow_methods = var.allowed_methods
    allow_origins = var.allowed_origins
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.api.id
  name = "$default"
  auto_deploy = true
}

