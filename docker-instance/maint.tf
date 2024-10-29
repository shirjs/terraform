
resource "aws_instance" "k3s_instance" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = var.instance_type
	vpc_security_group_ids = [aws_security_group.k3s_security_group.id]
	key_name = "shir_ws1key"

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    deploy_script = file("${path.module}/scripts/deploy.sh"),
    dev_tools_script = file("${path.module}/scripts/dev-tools.sh")
  })


  tags = {
    Name = var.instance_name
  }
}

resource "aws_security_group" "k3s_security_group" {
	name = var.sg_group_name
	description = var.sg_group_name

	ingress {
		description = "SSH access"
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["213.57.121.34/32"]
		}

  ingress {
    description = "k3s api server"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["213.57.121.34/32"]
  }

  ingress {
    description = "kubelet API"
    from_port = 10250
    to_port = 10250
    protocol = "tcp"
    cidr_blocks = ["213.57.121.34/32"]
  }

  ingress {
    description = "k3s nodeport services"
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
    cidr_blocks = ["213.57.121.34/32"]
  }

  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "CoreDNS"
    from_port = 53
    to_port = 53
    protocol = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "CoreDNS"
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}



