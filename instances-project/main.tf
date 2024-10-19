provider "aws" {
  region = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc-project/terraform.tfstate"
  }
}

resource "aws_instance" "gitlab" {
  ami = var.gitlab_ami
  instance_type = "t2.large"
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_cidrs[0]
  private_ip = "10.0.135.195"

  tags = {
    Name = "gitlab"
  }
}

resource "aws_instance" "jenkins_controller" {
  ami = var.jenkins_controller_ami
  instance_type = "t2.medium"
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_cidrs[0]
  private_ip = "10.0.143.155"

  tags = {
    Name = "jenkins-controller"
  }
}

resource "aws_instance" "nginx_weatherapp" {
  ami = var.nginx_weatherapp_ami
  instance_type = "t2.micro"
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_cidrs[0]
  private_ip = "10.0.137.165"

  tags = {
    Name = "nginx-weatherapp"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami = var.jenkins_agent_ami
  instance_type = "t2.micro"
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_cidrs[0]
  private_ip = "10.0.143.229"

  tags = {
    Name = "jenkins-agent"
  }
}