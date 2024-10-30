variable "bucket_name" {
  description = "name of the s3 bucket"
  type = string
}

# variable "lambda_integrations" {
#   description = "list of lambda function configurations"
#   type = list(object({
#     function_name = string
#     api_endpoint = string
#     route_path = string
#     button_text = string
#   }))
# }

