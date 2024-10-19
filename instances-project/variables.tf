variable "region" {
  description = "AWS region"
  type = string
  default = "us-east-1"
}

variable "gitlab_ami" {
  description = "ami id for gitlab instance"
  type = string
}

variable "jenkins_controller_ami" {
  description = "ami id for jenkins controller instance"
  type = string
}

variable "nginx_weatherapp_ami" {
  description = "ami id for nginx weatherapp instance"
  type = string
}

variable "jenkins_agent_ami" {
  description = "ami id for jenkins agent instance"
  type = string
}