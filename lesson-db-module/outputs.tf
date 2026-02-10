# S3 Backend Outputs
output "s3_bucket_name" {
  description = "Назва S3 bucket для Terraform state"
  value = module.s3_backend.s3_bucket_id
}

output "dynamodb_table_name" {
  description = "Назва DynamoDB таблиці для state locking"
  value = module.s3_backend.dynamodb_table_name
}

# VPC Outputs
output "vpc_id" {
  description = "ID VPC"
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR блок VPC"
  value = module.vpc.vpc_cidr
}

output "database_subnet_ids" {
  description = "ID підмереж для баз даних"
  value = module.vpc.database_subnet_ids
}

output "private_subnet_ids" {
  description = "ID приватних підмереж"
  value = module.vpc.private_subnet_ids
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value = module.ecr.repository_url
}

# EKS Outputs
output "eks_cluster_name" {
  description = "Назва EKS кластеру"
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint EKS кластеру"
  value = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Версія Kubernetes"
  value = module.eks.cluster_version
}

# RDS Outputs
output "db_endpoint" {
  description = "Endpoint для підключення до БД"
  value = module.rds.endpoint
}

output "db_port" {
  description = "Порт БД"
  value = module.rds.port
}

output "db_type" {
  description = "Тип БД (RDS або Aurora)"
  value = module.rds.db_type
}

output "db_engine" {
  description = "Двигун БД"
  value = module.rds.engine
}

output "db_security_group_id" {
  description = "ID Security Group БД"
  value = module.rds.security_group_id
}

output "db_name" {
  description = "Назва бази даних"
  value = module.rds.database_name
}

output "db_username" {
  description = "Ім'я користувача БД"
  value = module.rds.master_username
  sensitive   = true
}

# RDS специфічні outputs
output "rds_instance_address" {
  description = "Адреса RDS інстансу (якщо use_aurora = false)"
  value = module.rds.rds_instance_address
}

# Aurora специфічні outputs
output "aurora_cluster_endpoint" {
  description = "Writer endpoint Aurora кластеру (якщо use_aurora = true)"
  value = module.rds.aurora_cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint Aurora кластеру (якщо use_aurora = true)"
  value = module.rds.aurora_cluster_reader_endpoint
}

# Connection Information
output "connection_string" {
  description = "Приклад команди для підключення до БД"
  value = var.use_aurora ? (
    var.db_engine == "postgres" || var.db_engine == "aurora-postgresql" ?
      "psql -h ${try(split(":", module.rds.endpoint)[0], "pending")} -p ${module.rds.port} -U ${var.db_master_username} -d ${var.db_name}" :
      "mysql -h ${try(split(":", module.rds.endpoint)[0], "pending")} -P ${module.rds.port} -u ${var.db_master_username} -p ${var.db_name}"
    ) : (
    var.db_engine == "postgres" ?
      "psql -h ${try(split(":", module.rds.endpoint)[0], "pending")} -p ${module.rds.port} -U ${var.db_master_username} -d ${var.db_name}" :
      "mysql -h ${try(split(":", module.rds.endpoint)[0], "pending")} -P ${module.rds.port} -u ${var.db_master_username} -p ${var.db_name}"
  )
}

# Jenkins Outputs (якщо enable_jenkins = true)
output "jenkins_url" {
  description = "URL Jenkins (якщо увімкнено)"
  value = var.enable_jenkins ? "Виконайте: kubectl get svc -n ${var.jenkins_namespace}" : null
}

# ArgoCD Outputs (якщо enable_argocd = true)
output "argocd_url" {
  description = "URL ArgoCD (якщо увімкнено)"
  value = var.enable_argocd ? "Виконайте: kubectl get svc -n ${var.argocd_namespace}" : null
}
