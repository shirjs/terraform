output "instance_public_ip" {
  description = "public ip of the ec2 instance of the k3s master"
  value = aws_instance.k3s_instance.public_ip
}