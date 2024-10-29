resource "aws_lambda_function" "lambda" {
  filename = var.deployment_package_path
  function_name = var.lambda_function_name
  role = var.lambda_role_arn
  handler = var.lambda_handler
  source_code_hash = filebase64sha256(var.deployment_package_path)
  runtime = var.lambda_runtime
  timeout = var.lambda_timeout

  environment {
    variables = {
      PYTHONPATH = "/var/task/package"
    }
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = var.api_id
  integration_type = "AWS_PROXY"
  connection_type = "INTERNET"
  description = "${var.lambda_function_name} integration"
  # post is hardcoded for now to avoid confusion with cors rules
  integration_method = "POST"
  integration_uri = aws_lambda_function.lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id = var.api_id
  route_key = "POST /${var.route_path}"
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id = "AllowExecutionFrom${title(var.lambda_function_name)}APIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${var.api_execution_arn}/*/*"
}