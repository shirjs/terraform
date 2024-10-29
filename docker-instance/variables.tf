variable "instance_name" {
  description = "the docker instance name"
  default = "docker-instance"
}

variable "sg_group_name" {
  description = "security group name"
  default = "docker-instance-sg"
}

variable "instance_type" {
  description = "type of instance"
  default = "t2.large"
}
