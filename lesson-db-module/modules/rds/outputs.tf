output "db_type" {
  description = "Тип бази даних (RDS або Aurora)"
  value = var.use_aurora ? "Aurora" : "RDS"
}

output "engine" {
  description = "Двигун бази даних"
  value = local.engine_name
}

output "rds_instance_endpoint" {
  description = "Endpoint для підключення до RDS"
  value = var.use_aurora ? null : try(aws_db_instance.this[0].endpoint, null)
}

output "rds_instance_address" {
  description = "Hostname RDS інстансу"
  value = var.use_aurora ? null : try(aws_db_instance.this[0].address, null)
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint для підключення до Aurora кластеру"
  value = var.use_aurora ? try(aws_rds_cluster.aurora[0].endpoint, null) : null
}

output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint для підключення до Aurora кластеру"
  value = var.use_aurora ? try(aws_rds_cluster.aurora[0].reader_endpoint, null) : null
}

output "endpoint" {
  description = "Primary endpoint для підключення до БД"
  value = var.use_aurora ? (
    try(aws_rds_cluster.aurora[0].endpoint, null)
    ) : (
    try(aws_db_instance.this[0].endpoint, null)
  )
}

output "database_name" {
  description = "Назва бази даних"
  value = var.database_name
}

output "master_username" {
  description = "Ім'я головного користувача"
  value = var.master_username
  sensitive   = true
}

output "port" {
  description = "Порт для підключення до БД"
  value = local.db_port
}

output "security_group_id" {
  description = "ID Security Group для БД"
  value = aws_security_group.db.id
}

output "db_subnet_group_id" {
  description = "ID DB Subnet Group"
  value = aws_db_subnet_group.this.id
}
