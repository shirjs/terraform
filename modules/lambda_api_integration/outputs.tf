output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "integration_id" {
  value = aws_apigatewayv2_integration.lambda_integration.id
}

output "debug_env_vars" {
  value = aws_lambda_function.lambda.environment[0].variables
  sensitive = true
}