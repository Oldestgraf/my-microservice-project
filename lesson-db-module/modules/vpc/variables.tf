variable "project_name" {
  description = "Назва проекту"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR блок для VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR блоки для публічних підмереж"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR блоки для приватних підмереж"
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR блоки для підмереж баз даних"
  type = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "enable_nat_gateway" {
  description = "Чи створювати NAT Gateway"
  type = bool
  default = true
}

variable "single_nat_gateway" {
  description = "Чи використовувати один NAT Gateway для всіх AZ (економить кошти)"
  type = bool
  default = true
}

variable "tags" {
  description = "Додаткові теги"
  type = map(string)
  default = {}
}
