variable "vpc_cidr" {
  description = "cidr block for the vpc"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "name of the vpc"
  type = string
  default = "vpc-project"
}

variable "azs" {
  description = "availability zones"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type = list(string)
  default = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for public subets"
  type = list(string)
  default = ["10.0.0.0/20", "10.0.16.0/20"]
}

