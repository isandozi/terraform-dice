locals {
  az_names    = data.aws_availability_zones.azs.names
  pub_sub_ids = aws_subnet.public.*.id
  priv_sub_ids = aws_subnet.private.*.id
}

resource "aws_vpc" "my_app" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name        = "DiceVPC"
  }
}

resource "aws_subnet" "public" {
  count                   = length(local.az_names)
  vpc_id                  = aws_vpc.my_app.id
  cidr_block              = cidrsubnet("${aws_vpc.my_app.cidr_block}", 8, count.index)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_app.id

  tags = {
    Name = "DiceVPC_IG"
  }
}

resource "aws_route_table" "prt" {
  vpc_id = aws_vpc.my_app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "DiceVPC_Public_RT"
  }
}

resource "aws_route_table_association" "pub_sub_association" {
  count          = length(local.az_names)
  subnet_id      = local.pub_sub_ids[count.index]
  route_table_id = aws_route_table.prt.id
}

resource "aws_subnet" "private" {
  count             = length(local.az_names)
  vpc_id            = aws_vpc.my_app.id
  cidr_block        = cidrsubnet("${aws_vpc.my_app.cidr_block}", 8, count.index + length(local.az_names))
  availability_zone = local.az_names[count.index]

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.my_app.id

  route {
    cidr_block  = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }

  tags = {
    Name = "DiceVPC_Private_RT"
  }
}

resource "aws_route_table_association" "private_rt_assocation" {
  count          = length(local.az_names)
  subnet_id      = local.priv_sub_ids[count.index]
  route_table_id = aws_route_table.privatert.id
}

resource "aws_eip" "lb" {
  vpc      = true
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = local.pub_sub_ids[0]

  tags = {
    Name = "DiceVPC_NAT"
  }
}
