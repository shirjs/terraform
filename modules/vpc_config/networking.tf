resource "aws_internet_gateway" "main" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat" {
  count = length(data.terraform_remote_state.vpc.outputs.public_subnet_ids)
  domain = "vpc" 
  tags = {
    Name = "nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "main" {
  count = length(data.terraform_remote_state.vpc.outputs.public_subnet_ids)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[count.index]
  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  count = length(data.terraform_remote_state.vpc.outputs.private_subnet_ids)
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = {
    Name = "private-route-table-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(data.terraform_remote_state.vpc.outputs.public_subnet_ids)
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(data.terraform_remote_state.vpc.outputs.private_subnet_ids)
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id
}