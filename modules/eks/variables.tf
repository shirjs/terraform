variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "eks cluster name"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "kubernetes version for eks cluster"
  type        = string
  default     = "1.30"
}

variable "node_group_name" {
  description = "node group name"
  type        = string
  default     = "my-node-group"
}

variable "node_group_instance_types" {
  description = "list of instance types for the eks node group"
  type        = list(string)
  default     = ["t2.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of worked nodes"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Max number of worker nodes"
  type        = number
  default     = 4
}

variable "node_group_min_size" {
  description = "Min number of worker nodes"
  type        = number
  default     = 1
}
