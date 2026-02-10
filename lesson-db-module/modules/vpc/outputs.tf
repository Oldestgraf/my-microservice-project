output "vpc_id" {
  description = "ID VPC"
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR блок VPC"
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "ID публічних підмереж"
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "ID приватних підмереж"
  value = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "ID підмереж для баз даних"
  value = aws_subnet.database[*].id
}

output "nat_gateway_ids" {
  description = "ID NAT Gateways"
  value = aws_nat_gateway.main[*].id
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value = aws_internet_gateway.main.id
}
