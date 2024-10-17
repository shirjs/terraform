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