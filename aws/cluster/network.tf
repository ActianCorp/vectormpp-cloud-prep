resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_name}"
  }
}

data "aws_availability_zones" "available" {}

locals {
  # EKS controll plane can not be created in the following zones
  disallowed_az_ids = {
    "us-east-1"    = "use1-az3"
    "us-west-1"    = "usw1-az2"
    "ca-central-1" = "cac1-az3"
  }
  disallowed_az_name = lookup(var.az_map, lookup(local.disallowed_az_ids, var.region, ""), null)
  supported_azs = tolist(setsubtract(data.aws_availability_zones.available.names, [local.disallowed_az_name]))
}

output "debug_supported_azs" {
  description = "List of allowed AZs after filtering"
  value       = local.supported_azs
  sensitive   = false
}

resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  availability_zone       = local.supported_azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name}-public-${count.index}"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 3)
  availability_zone       = local.supported_azs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.cluster_name}-private-${count.index}"
  }
}

# internet gateway and route
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public"
  }
}

resource "aws_route_table_association" "public_route_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# nat gateway and route
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.cluster_name}-private"
  }
}

resource "aws_route_table_association" "private_route_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
