locals {
  common_tages ={
     Name="Ournetwork"
     Environment = "Production"
  }
}


resource "aws_vpc" "ournetwork" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = merge(local.common_tages) 
}


resource "aws_subnet" "public" {
  count = var.public_subnet_count
  vpc_id     = aws_vpc.ournetwork.id
  cidr_block = cidrsubnet(aws_vpc.ournetwork.cidr_block, 8, count.index)
  availability_zone = "us-east-1a"
  tags = merge(local.common_tages,{
    visibility="Public"
  })
  
}



resource "aws_subnet" "private" {
  count=var.private_subnet_count
  vpc_id     = aws_vpc.ournetwork.id
  cidr_block = cidrsubnet(aws_vpc.ournetwork.cidr_block, 8, count.index)
  availability_zone = "us-east-1b"
  tags =merge(local.common_tages,{
    visibility="Private"
  })
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ournetwork.id
  tags = merge(local.common_tages)
}

resource "aws_eip" "nat" {
  domain = "vpc"  
  
  tags = merge(local.common_tages)
  
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private.id

  tags = merge(local.common_tages)
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ournetwork.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}