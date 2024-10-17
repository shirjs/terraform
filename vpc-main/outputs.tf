output "vpc_id" {
  description = "id of the vpc"
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "ids of the public subnets"
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "ids of the private subnets"
  value = module.vpc.private_subnet_ids
}