resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-public-rt"
      Tier = "Public"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 1

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-private-rt-${count.index + 1}"
      Tier = "Private"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0

  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway && !var.single_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

resource "aws_route_table" "database" {
  count = length(var.database_subnet_cidrs) > 0 ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-database-rt"
      Tier = "Database"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)

  subnet_id = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}
