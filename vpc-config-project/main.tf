provider "aws" {
  region = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc-project/terraform.tfstate"
  }
}

module "vpc_config" {
  source = "../modules/vpc_config"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"

  route_table_ids = module.vpc_config.private_route_table_ids

  tags = {
    Name = "s3-gateway-endpoint"
  }
}