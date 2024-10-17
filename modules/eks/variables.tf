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


variable "region" {
  description = "AWS region"
  type        = string
  # default     = "us-east-1"
}

variable "cluster_name" {
  description = "eks cluster name"
  type        = string
  # default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "kubernetes version for eks cluster"
  type        = string
  # default     = "1.30"
}

variable "node_group_name" {
  description = "node group name"
  type        = string
  # default     = "my-node-group"
}

variable "node_group_instance_types" {
  description = "list of instance types for the eks node group"
  type        = list(string)
  # default     = ["t2.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of worked nodes"
  type        = number
  # default     = 2
}

variable "node_group_max_size" {
  description = "Max number of worker nodes"
  type        = number
  # default     = 4
}

variable "node_group_min_size" {
  description = "Min number of worker nodes"
  type        = number
  # default     = 1
}

variable "endpoint_private_access" {
  description = "amazon eks private api server endpoint enabled/disabled"
  type = bool
  default = true
}

variable "endpoint_public_access" {
  description = "amazon eks public api server endpoint enabled/disabled"
  type = bool
  default = false
}

variable "enabled_cluster_log_types" {
  description = "a list of the desired control plane logging to enable"
  type = list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "additional_security_group_ids" {
  description = "list of additional security group ids to attach to the cluster"
  type = list(string)
  default = []
}

variable "tags" {
  description = "a map of tags to add to all resources"
  type = map(string)
  default = {}
}
