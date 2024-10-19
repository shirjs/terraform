resource "aws_security_group" "gitlab" {
  name = "gitlab-sg"
  description = "security group for gitlab instance"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "port 50000 from jenkins controller"
    from_port = 50000
    to_port = 50000
    protocol = "tcp"
    security_groups = [aws_security_group.jenkins_controller.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gitlab-sg"
  }
}

resource "aws_security_group" "jenkins_controller" {
  name = "jenkins-controller-sg"
  description = "security grtoup for jenkins controller"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  dynamic "ingress" {
    for_each = [8080, 50000, 22]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-controller-sg"
  }
}

resource "aws_security_group" "nginx_weatherapp" {
  name = "nginx-weatherapp-sg"
  description = "security group for nginx weatherapp"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh from jenkins agent"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.jenkins_agent.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-weatherapp-sg"
  }
}

resource "aws_security_group" "jenkins_agent" {
  name = "jenkins-agent-sg"
  description = "security group for jenkins agent"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "port 50000 from jenkins controller"
    from_port = 50000
    to_port = 50000
    protocol = "tcp"
    security_groups = [aws_security_group.jenkins_controller.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-agent-sg"
  }
}

