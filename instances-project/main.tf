provider "aws" {
  region = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc-project/terraform.tfstate"
  }
}

data "aws_iam_instance_profile" "system_manager_profile" {
  name = "aws_system_manager_role"
}

resource "aws_instance" "gitlab" {
  ami = var.gitlab_ami
  instance_type = "t2.large"
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  private_ip = "10.0.135.192"
  iam_instance_profile = data.aws_iam_instance_profile.system_manager_profile.name
  vpc_security_group_ids = [aws_security_group.gitlab.id]

  tags = {
    Name = "gitlab"
  }
}

resource "aws_instance" "jenkins_controller" {
  ami = var.jenkins_controller_ami
  instance_type = "t2.medium"
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  private_ip = "10.0.143.155"
  iam_instance_profile = data.aws_iam_instance_profile.system_manager_profile.name
  vpc_security_group_ids = [aws_security_group.jenkins_controller.id]

  tags = {
    Name = "jenkins-controller"
  }
}

resource "aws_instance" "nginx_weatherapp" {
  ami = var.nginx_weatherapp_ami
  instance_type = "t2.micro"
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  private_ip = "10.0.137.165"
  iam_instance_profile = data.aws_iam_instance_profile.system_manager_profile.name
  vpc_security_group_ids = [aws_security_group.nginx_weatherapp.id]

  tags = {
    Name = "nginx-weatherapp"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami = var.jenkins_agent_ami
  instance_type = "t2.micro"
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  private_ip = "10.0.143.229"
  iam_instance_profile = data.aws_iam_instance_profile.system_manager_profile.name
  vpc_security_group_ids = [aws_security_group.jenkins_agent.id]

  tags = {
    Name = "jenkins-agent"
  }
}