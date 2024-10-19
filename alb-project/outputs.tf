output "alb_dns_name" {
  description = "the dns name of the load balancer"
  value = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "canonical hosted zone id of the load balancer, not the route53, used in route53"
  value = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "the arn of the load balancer"
  value = aws_lb.main.arn
}