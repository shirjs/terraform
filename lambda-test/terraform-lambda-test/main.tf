provider "aws" {
  region = "us-east-1"
}

module "api_gateway" {
  source = "../../modules/api_gateway"

  api_name = "hello-api"
}

# iam roles will be used across lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "hello_lambda_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_role.name
}

module "hello_lambda" {
  source = "../../modules/lambda_api_integration"
  lambda_function_name = "hello_function"
  lambda_handler = "lambda_function.lambda_handler"
  lambda_role_arn = aws_iam_role.lambda_role.arn
  api_id = module.api_gateway.api_id
  api_execution_arn = module.api_gateway.api_execution_arn
  route_path = "hello"
  deployment_package_path = "../src/lambda_functions/test_function/deployment_package.zip"
}


module "website" {
  source = "../../modules/s3_website"

  bucket_name = "hello-lambda-website-bucket-${random_string.suffix.result}"

  lambda_integrations = [
    {
      function_name = module.hello_lambda.lambda_function_name
      api_endpoint = module.api_gateway.api_endpoint
      route_path = "hello"
      button_text = "activate function"
    }
  ]
}

resource "random_string" "suffix" {
  length = 8
  special = false
  upper = false
}

