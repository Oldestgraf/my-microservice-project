resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(
    {
      Name = "${var.project_name}-vpc"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-igw"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.project_name}-public-${count.index + 1}"
      Tier = "Public"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name = "${var.project_name}-private-${count.index + 1}"
      Tier = "Private"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)

  vpc_id = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    {
      Name = "${var.project_name}-database-${count.index + 1}"
      Tier = "Database"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)) : 0
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.project_name}-nat-eip-${count.index + 1}"
      ManagedBy = "Terraform"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.project_name}-nat-${count.index + 1}"
      ManagedBy = "Terraform"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

data "aws_availability_zones" "available" {
  state = "available"
}
