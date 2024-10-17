provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../terraform_vpc/terraform.tfstate"
  }
}
