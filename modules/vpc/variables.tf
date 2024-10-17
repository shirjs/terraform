variable "vpc_cidr" {
  description = "cidr block for vpc"
  type = string
}

variable "vpc_name" {
  description = "name of vpc"
  type = string
}

variable "azs" {
  description = "availability zones"
  type = list(string)
}

variable "public_subnet_cidrs" {
  description = "cidr blocks for public subnets"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "cidr blocks for private subnets"
  type = list(string)
}

