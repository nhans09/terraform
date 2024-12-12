# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Makuta-Infra-VPC"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Infra-Public-Subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Infra-Private-Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Infra-IGW"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Infra-PublicRouteTable"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Create an Elastic IP for the NAT Gateway
# resource "aws_eip" "nat_eip" {
#   domain = "vpc"
# }

# # Create a NAT Gateway in the public subnet
# resource "aws_nat_gateway" "nat_gw" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.public.id

#   tags = {
#     Name = "Infra-NATGateway"
#   }
# }

# # Create a route table for the private subnet
# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gw.id
#   }

#   tags = {
#     Name = "Infra-PrivateRouteTable"
#   }
# }

# # Associate the private route table with the private subnet
# resource "aws_route_table_association" "private_association" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private_rt.id
# }