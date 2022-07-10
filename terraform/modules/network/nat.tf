# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public-subnet.id

#   tags = {
#     Name = "NAT gateway"
#   }
# }


# resource "aws_eip" "nat" {
#   vpc = true
# }


resource "aws_route_table" "private-table" {
  vpc_id = aws_vpc.main.id
  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   # nat_gateway_id = aws_nat_gateway.nat.id
  # }
  tags = {
    Name = "private-table"
  }
}


resource "aws_route_table" "public-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-table"
  }
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-table.id
}


resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-table.id
}