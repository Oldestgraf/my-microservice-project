# Загальні змінні
variable "aws_region" {
  description = "AWS регіон"
  type = string
  default = "us-east-1"
}

variable "project_name" {
  description = "Назва проекту"
  type = string
  default = "rds-homework"
}

variable "environment" {
  description = "Середовище (dev, staging, prod)"
  type = string
  default = "dev"
}

# S3 Backend змінні
variable "terraform_state_bucket" {
  description = "Назва S3 bucket для Terraform state"
  type = string
  default = "my-terraform-state-bucket-unique"
}

variable "terraform_state_lock_table" {
  description = "Назва DynamoDB таблиці для state locking"
  type = string
  default = "terraform-state-lock"
}

# VPC змінні
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
  description = "Використовувати один NAT Gateway"
  type = bool
  default = true
}

# ECR змінні
variable "ecr_repository_name" {
  description = "Назва ECR репозиторію"
  type = string
  default = "django-app"
}

variable "ecr_scan_on_push" {
  description = "Сканувати образи при push"
  type = bool
  default = true
}

# EKS змінні
variable "eks_cluster_name" {
  description = "Назва EKS кластеру"
  type = string
  default = "rds-homework-eks"
}

variable "eks_kubernetes_version" {
  description = "Версія Kubernetes"
  type = string
  default = "1.28"
}

variable "eks_instance_types" {
  description = "Типи інстансів для EKS node group"
  type = list(string)
  default = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Бажана кількість нод"
  type = number
  default = 2
}

variable "eks_node_min_size" {
  description = "Мінімальна кількість нод"
  type = number
  default = 1
}

variable "eks_node_max_size" {
  description = "Максимальна кількість нод"
  type = number
  default = 3
}

# RDS змінні
variable "use_aurora" {
  description = "Використовувати Aurora (true) або RDS (false)"
  type = bool
  default = false
}

variable "db_engine" {
  description = "Тип двигуна БД"
  type = string
  default = "postgres"
}

variable "db_engine_version" {
  description = "Версія двигуна БД"
  type = string
  default = "16.1"
}

variable "db_instance_class" {
  description = "Клас інстансу БД"
  type = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Об'єм сховища в GB (тільки для RDS)"
  type = number
  default = 20
}

variable "db_storage_type" {
  description = "Тип сховища"
  type = string
  default = "gp3"
}

variable "db_storage_encrypted" {
  description = "Чи шифрувати сховище"
  type = bool
  default = true
}

variable "db_name" {
  description = "Назва бази даних"
  type = string
  default = "mydb"
}

variable "db_master_username" {
  description = "Ім'я головного користувача"
  type = string
  default = "admin"
  sensitive = true
}

variable "db_master_password" {
  description = "Пароль головного користувача"
  type = string
  sensitive = true
}

variable "db_multi_az" {
  description = "Multi-AZ розгортання"
  type = bool
  default = false
}

variable "db_publicly_accessible" {
  description = "Публічний доступ до БД"
  type = bool
  default = false
}

variable "aurora_cluster_instances" {
  description = "Кількість інстансів в Aurora кластері"
  type = number
  default = 1
}

variable "db_backup_retention_period" {
  description = "Період зберігання бекапів (днів)"
  type = number
  default = 7
}

variable "db_skip_final_snapshot" {
  description = "Пропускати фінальний snapshot"
  type = bool
  default = false
}

variable "db_performance_insights_enabled" {
  description = "Увімкнути Performance Insights"
  type = bool
  default = false
}

variable "db_cloudwatch_logs_exports" {
  description = "Типи логів для CloudWatch"
  type = list(string)
  default = []
}

variable "db_deletion_protection" {
  description = "Захист від видалення"
  type = bool
  default = false
}

# Jenkins змінні
variable "enable_jenkins" {
  description = "Чи створювати Jenkins"
  type = bool
  default = false
}

variable "jenkins_namespace" {
  description = "Kubernetes namespace для Jenkins"
  type = string
  default = "jenkins"
}

variable "jenkins_service_type" {
  description = "Тип сервісу Jenkins"
  type = string
  default = "LoadBalancer"
}

variable "jenkins_admin_password" {
  description = "Пароль адміністратора Jenkins"
  type = string
  default = "admin123"
  sensitive = true
}

# ArgoCD змінні
variable "enable_argocd" {
  description = "Чи створювати ArgoCD"
  type = bool
  default = false
}

variable "argocd_namespace" {
  description = "Kubernetes namespace для ArgoCD"
  type = string
  default = "argocd"
}

variable "argocd_server_service_type" {
  description = "Тип сервісу ArgoCD server"
  type = string
  default = "LoadBalancer"
}

variable "argocd_app_name" {
  description = "Назва додатку в ArgoCD"
  type = string
  default = "django-app"
}

variable "argocd_app_namespace" {
  description = "Namespace для розгортання додатку"
  type = string
  default = "django"
}

variable "argocd_repo_url" {
  description = "URL Git репозиторію"
  type = string
  default = ""
}

variable "argocd_chart_path" {
  description = "Шлях до Helm chart"
  type = string
  default = "charts/django-app"
}

variable "argocd_target_revision" {
  description = "Git branch/tag"
  type = string
  default = "main"
}
