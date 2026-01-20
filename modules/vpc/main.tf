locals {
  common_tags = {
    Name        = "Ournetwork"
    Environment = "Production"
  }
}


resource "aws_vpc" "ournetwork" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = local.common_tags
}


resource "aws_subnet" "public" {
  count             = var.public_subnet_count
  vpc_id            = aws_vpc.ournetwork.id
  cidr_block        = cidrsubnet(aws_vpc.ournetwork.cidr_block, 8, count.index)
  availability_zone = "us-east-1a"
  
  tags = merge(local.common_tags, {
    Name       = "Public-Subnet-${count.index + 1}"
    visibility = "Public"
  })
}


resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.ournetwork.id
 
  cidr_block        = cidrsubnet(aws_vpc.ournetwork.cidr_block, 8, count.index + 10)
  availability_zone = "us-east-1b"

  tags = merge(local.common_tags, {
    Name       = "Private-Subnet-${count.index + 1}"
    visibility = "Private"
  })
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ournetwork.id
  tags   = local.common_tags
}


resource "aws_eip" "eip" {
  domain     = "vpc"
  tags       = local.common_tags
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id 

  tags       = local.common_tags
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ournetwork.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(local.common_tags, { Name = "Public-RT" })
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ournetwork.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(local.common_tags, { Name = "Private-RT" })
}


resource "aws_route_table_association" "public_assoc" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id 
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private_assoc" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id 
  route_table_id = aws_route_table.private.id
}