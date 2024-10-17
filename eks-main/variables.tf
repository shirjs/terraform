variable "region" {
  description = "aws region"
  type = string
}

variable "cluster_name" {
  description = "name of the eks cluster"
  type = string
}

variable "cluster_version" {
  description = "kubernetes version for eks cluster"
  type = string
}

variable "node_group_name" {
  description = "name of the eks node group"
  type = string
}

variable "node_group_instance_types" {
  description = "list of instance types for the eks node group"
  type = list(string)
}

variable "node_group_desired_size" {
  description = "desired number of worker nodes"
  type = number
}

variable "node_group_min_size" {
  description = "minimum number of worker nodes"
  type = number
}

variable "node_group_max_size" {
  description = "max number of worker nodes"
  type = number
}

variable "endpoint_private_access" {
  description = "true/false private api server endpoint"
  type = bool
  default = true
}

variable "endpoint_public_access" {
  description = "true/false public api server endpoint"
  type = bool
  default = false
}

variable "enabled_cluster_log_types" {
  description = "a list of control plane logging to enable"
  type = list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "tags" {
  description = "a map of tags to add to all resources"
  type = map(string)
  default = {}
}
