variable "aws_region" {
  description = "aws region"
  type = string
  default = "us-east-1"
}

variable "ssl_certificate_arn" {
  description = "ARN of the ssl certificate for https"
  type = string
  # adding to tfvars
}

variable "route53_zone_id" {
  description = "Route53 hosted zone id"
  type = string
  # adding to tfvars
}