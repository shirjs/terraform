variable "lambda_function_name" {
  description = "name of the lambda function"
  type = string
}

variable "lambda_handler" {
  description = "handler function for lambda"
  type = string
}

variable "lambda_runtime" {
  description = "runtime for lambda function"
  type = string
  default = "python3.12"
}

variable "lambda_timeout" {
  description = "timeout for lambda function in seconds"
  type = number
  default = 5
}

variable "lambda_role_arn" {
  description = "arn of the iam role for lambda"
  type = string
}

variable "api_id" {
  description = "ID of the API Gateway" 
  type = string
}

variable "route_path" {
  description = "path for the api gateway route"
  type = string
}

variable "deployment_package_path" {
  description = "path to the deployment package zip file"
  type = string
}

variable "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}