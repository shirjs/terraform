variable "api_name" {
  description = "name of the api gateway"
  type = string
}

variable "allowed_origins" {
  description = "list of allowed cors origins"
  type = list(string)
  default = ["*"]
}

variable "allowed_methods" {
  description = "list of allowed http methods"
  type = list(string)
  default = ["GET", "POST", "OPTIONS"]
}

variable "allowed_headers" {
  description = "list of allowed headers"
  type = list(string)
  default = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
}

