output "api_id" {
  description = "ID of the created api gateway"
  value = aws_apigatewayv2_api.api.id
}

output "api_endpoint" {
  description = "endpoint url of the api gateway"
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "api_execution_arn" {
  description = "execution arn of the api gateway"
  value = aws_apigatewayv2_api.api.execution_arn
}

output "stage_id" {
  description = "ID of the default stage"
  value = aws_apigatewayv2_stage.default.id
}