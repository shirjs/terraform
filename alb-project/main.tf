provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc-project/terraform.tfstate"
  }
}

data "terraform_remote_state" "instances" {
  backend = "local"
  config = {
    path = "../instances-project/terraform.tfstate"
  }
}

resource "aws_lb" "main" {
  name = "main-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "main-alb"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.ssl_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code = "404"
    }
  }
}

resource "aws_lb_target_group" "gitlab" {
  name = "gitlab-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path = "/users/sign_in"
    healthy_threshold = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_target_group_attachment" "gitlab" {
  target_group_arn = aws_lb_target_group.gitlab.arn
  target_id = data.terraform_remote_state.instances.outputs.gitlab_instance_id
  port = 80
}

resource "aws_lb_listener_rule" "gitlab" {
  listener_arn = aws_lb_listener.https.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.gitlab.arn
  }

  condition {
    host_header {
      values = ["gitlab1.yawa19.com"]
    }
  }
}

resource "aws_lb_target_group" "jenkins" {
  name = "jenkins-tg"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path = "/login"
    healthy_threshold = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id = data.terraform_remote_state.instances.outputs.jenkins_controller_instance_id
  port = 8080
}

resource "aws_lb_listener_rule" "jenkins" {
  listener_arn = aws_lb_listener.https.arn
  priority = 200

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

  condition {
    host_header {
      values = ["jenkins1.yawa19.com"]
    }
  }
}

resource "aws_lb_target_group" "weatherapp" {
  name = "weatherapp-tg"
  port = 9000
  protocol = "HTTP"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path = "/"
    healthy_threshold = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_target_group_attachment" "weatherapp" {
  target_group_arn = aws_lb_target_group.weatherapp.arn
  target_id = data.terraform_remote_state.instances.outputs.nginx_weatherapp_instance_id
  port = 9000
}

resource "aws_lb_listener_rule" "weatherapp" {
  listener_arn = aws_lb_listener.https.arn
  priority = 300

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.weatherapp.arn
  }

  condition {
    host_header {
      values = ["app1.yawa19.com"]
    }
  }
}

resource "aws_security_group" "alb" {
  name = "alb-sg"
  description = "security group for alb"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "https from anywhere"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_route53_record" "gitlab" {
  zone_id = var.route53_zone_id
  name = "gitlab1.yawa19.com"
  type = "CNAME"
  ttl = "300"
  records = [aws_lb.main.dns_name]
}

resource "aws_route53_record" "jenkins" {
  zone_id = var.route53_zone_id
  name = "jenkins1.yawa19.com"
  type = "CNAME"
  ttl = "300"
  records = [aws_lb.main.dns_name]
}

resource "aws_route53_record" "app" {
  zone_id = var.route53_zone_id
  name = "app1.yawa19.com"
  type = "CNAME"
  ttl = "300"
  records = [aws_lb.main.dns_name]
}

