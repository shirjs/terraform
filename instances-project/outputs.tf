output "gitlab_instance_id" {
  description = "id of the gitlab ec2 instance"
  value = aws_instance.gitlab.id
}

output "jenkins_controller_instance_id" {
  description = "id of the jenkins controller ec2 instance"
  value = aws_instance.jenkins_controller.id
}

output "nginx_weatherapp_instance_id" {
  description = "id of the nginx weatherapp ec2 instance"
  value = aws_instance.nginx_weatherapp.id
}

output "jenkins_agent_instance_id" {
  description = "id of the jenkins agent ec2 instance"
  value = aws_instance.jenkins_agent.id
}