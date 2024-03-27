provider "aws" {
     region = "ap-south-1"
     access_key = "AKIA6ODU4JJ6VRWVS35Q"
     secret_key = "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"
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block              = var.cidr_block
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = "Test VPC"
    }
}

# Create Internet Gateway and Attach it to VPC
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id    = 	aws_vpc.vpc.id
  tags      = {
    Name    = "Test IGW"
  }
}

# Create Public Subnet 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_block_pub1
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public Subnet 1"
  }
}

# Create Public Subnet 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  =  aws_vpc.vpc.id
  cidr_block              = var.cidr_block_pub2
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public Subnet 2"
  }
}

# Create Route Table and Add Public Route
resource "aws_route_table" "public-route-table" {
  vpc_id       = aws_vpc.vpc.id
  route {
    cidr_block = var.cidr_block_internet
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags       = {
    Name     = "Public Route Table"
  }
}

# Associate Public Subnet 1 to "Public Route Table"
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id           = aws_subnet.public-subnet-1.id
  route_table_id      = aws_route_table.public-route-table.id
}

# Associate Public Subnet 2 to "Public Route Table"
resource "aws_route_table_association" "public-subnet-2-route-table-association" {
  subnet_id           = aws_subnet.public-subnet-2.id
  route_table_id      = aws_route_table.public-route-table.id
}


# Create Private Subnet 1
resource "aws_subnet" "private-subnet-1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.cidr_block_private1
  availability_zone        = var.availability_zone
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "Private Subnet 1 | App Tier"
  }
}

# Create Private Subnet 2
resource "aws_subnet" "private-subnet-2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.cidr_block_private2
  availability_zone        = var.availability_zone
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "Private Subnet 2 | App Tier"
  }
}

# Create Route Table and Add Private Route
resource "aws_route_table" "private-route-table" {
  vpc_id       = aws_vpc.vpc.id
  tags       = {
    Name     = "Private Route Table"
  }
}

# Associate Private Subnet 1 to "Private Route Table"
resource "aws_route_table_association" "Private-subnet-1-route-table-association" {
  subnet_id           = aws_subnet.private-subnet-1.id
  route_table_id      = aws_route_table.private-route-table.id
}

# Associate Private Subnet 2 to "Private Route Table"
resource "aws_route_table_association" "Private-subnet-2-route-table-association" {
  subnet_id           = aws_subnet.private-subnet-2.id
  route_table_id      = aws_route_table.private-route-table.id
}

# Create NAT Gateway and Attach it to VPC
resource "aws_nat_gateway" "Nat-gateway-TEST" {
  allocation_id = "eipalloc-0fcb8ec01056658b7"
  subnet_id     = aws_subnet.public-subnet-1.id
 tags = {
    Name = "gw NAT"
  }
}


# Associate Private route table to "Nat-Gateway"
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = var.cidr_block_NAT
  nat_gateway_id         = aws_nat_gateway.Nat-gateway-TEST.id
}

resource "aws_instance" "terraform01" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id      = aws_subnet.private-subnet-1.id
  tags = {
    Name = "Terraform-Instance-private"
  }
}

#To create EC2 instance in Public-Subnet
resource "aws_instance" "terraform02" {
  ami = var.ami_id
  instance_type = var.instance_type
    subnet_id      = aws_subnet.public-subnet-1.id
  tags = {
    Name = "Terraform-Instance-public"
  }
}