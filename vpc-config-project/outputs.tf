output "vpc_id" {
  description = "id of the vpc"
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "public_subnet_ids" {
  description = "list of public subnet ids"
  value = data.terraform_remote_state.vpc.outputs.public_subnet_ids
}

output "private_subnet_ids" {
  description = "list of private subnet ids"
  value = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "list of nat gateway ids"
  value = module.vpc_config.nat_gateway_ids
}

output "public_route_table_id" {
  description = "id of the public route table"
  value = module.vpc_config.nat_gateway_ids
}

output "private_route_table_ids"  {
  description = "list of ids of private route tables"
  value = module.vpc_config.private_route_table_ids
}

output "s3_gateway_endpoint_id" {
  description = "id of the s3 gateway endpoint"
  value = aws_vpc_endpoint.s3.id
}
