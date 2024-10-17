output "cluster_id" {
  description = "the id of the eks cluster"
  value = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "the arn of the cluster"
  value = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "endpoint for eks control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "security group id attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_name" {
  description = "kubernetes cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "node_group_arn" {
  description = "amazon_group_arn"
  value = aws_eks_node_group.main.arn
}

