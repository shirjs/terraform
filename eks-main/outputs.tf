output "cluster_id" {
  description = "the id of the eks cluster"
  value = module.eks.cluster_id
}

output "cluster_arn" {
  description = "arn of the cluster"
  value = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "endpoint of eks control plane"
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "security group id attached to the eks cluster"
  value = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "the name of the eks cluster"
  value = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "base64 encoded certificate data required to communicate with the cluster"
  value = module.eks.cluster_certificate_authority_data
}

output "node_group_arn" {
  description = "arn of the eks node group"
  value = module.eks.node_group_arn
}

output "vpc_config_nat_gateway_ids" {
  description = "list of nat gateway ids"
  value = module.vpc_config.nat_gateway_ids
}

output "vpc_config_public_route_table_id" {
  description = "id of the public route table"
  value = module.vpc_config.public_route_table_id
}

output "vpc_config_private_route_table_ids" {
  description = "list of ids of private route tables"
  value = module.vpc_config.private_route_table_ids
}