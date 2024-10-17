output "nat_gateway_ids" {
  description = "list of nat gateway ids"
  value = aws_nat_gateway.main[*].id
}

output "public_route_table_id" {
  description = "id of the public route table"
  value = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "list of ids of private route tables"
  value = aws_route_table.private[*].id
}