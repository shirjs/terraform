resource "aws_security_group_rule" "gitlab_from_alb" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id = data.terraform_remote_state.instances.outputs.gitlab_sg_id
}

resource "aws_security_group_rule" "jenkins_from_alb" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id = data.terraform_remote_state.instances.outputs.jenkins_controller_sg_id
}

resource "aws_security_group_rule" "weatherapp_from_alb" {
  type = "ingress"
  from_port = 9000
  to_port = 9000
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id = data.terraform_remote_state.instances.outputs.nginx_weatherapp_sg_id
}