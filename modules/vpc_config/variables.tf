variable "region" {
  description = "region of implementation"
  default = "us-east-1"
}

variable "vpc_id" {
  description = "id of the vpc"
  type = string
}

variable "public_subnet_ids" {
  description = "list of public subnet ids"
  type = list(string)
}

variable "private_subnet_ids" {
  description = "list of private subnet ids"
  type = list(string)
}
