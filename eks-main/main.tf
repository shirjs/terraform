provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc-main/terraform.tfstate"
  }
}

module "vpc_config" {
  source = "../modules/vpc_config"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}

module "eks" {
  source = "../modules/eks"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  region = var.region

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version

  node_group_name = var.node_group_name
  node_group_instance_types = var.node_group_instance_types
  node_group_desired_size = var.node_group_desired_size
  node_group_min_size = var.node_group_min_size
  node_group_max_size = var.node_group_max_size

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access = var.endpoint_public_access

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = var.tags
}