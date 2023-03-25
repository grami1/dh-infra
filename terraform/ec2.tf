provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "aws_vpc" "dh_vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dh_vpc"
  }
}

resource "aws_internet_gateway" "dh_ig" {
  vpc_id = aws_vpc.dh_vpc.id

  tags = {
    Name = "dh_ig"
  }
}

resource "aws_route_table" "dh_route_table" {
  vpc_id = aws_vpc.dh_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dh_ig.id
  }

  tags = {
    Name = "dh_route_table"
  }
}

resource "aws_subnet" "dh_subnet" {
  vpc_id = aws_vpc.dh_vpc.id
  cidr_block = "10.1.0.0/24"

  tags = {
    Name = "dh_subnet"
  }
}

resource "aws_route_table_association" "dh_route_table_association" {
  subnet_id      = aws_subnet.dh_subnet.id
  route_table_id = aws_route_table.dh_route_table.id
}

resource "aws_security_group" "dh_security_group" {
  name = "dh_security_group"
  vpc_id = aws_vpc.dh_vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dh_ssh_security_group" {
  name = "dh_ssh_security_group"
  vpc_id = aws_vpc.dh_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dh_instance" {
  ami = "ami-005ee9e4d4fd438eb"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.dh_subnet.id
  security_groups = [aws_security_group.dh_security_group.id, aws_security_group.dh_ssh_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "dh_server"
  }
}