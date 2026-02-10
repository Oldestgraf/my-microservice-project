# Terraform Configuration
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = var.project_name
      Environment = var.environment
      ManagedBy = "Terraform"
    }
  }
}

# S3 Backend Module (для зберігання state)
module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = var.terraform_state_bucket
  dynamodb_table_name = var.terraform_state_lock_table

  tags = {
    Purpose = "Terraform State Storage"
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name

  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags = {
    Environment = var.environment
  }
}

# ECR Module (для Docker образів)
module "ecr" {
  source = "./modules/ecr"

  ecr_name = var.ecr_repository_name
  scan_on_push = var.ecr_scan_on_push
}

# EKS Module (Kubernetes кластер)
module "eks" {
  source = "./modules/eks"

  cluster_name = var.eks_cluster_name
  kubernetes_version = var.eks_kubernetes_version
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  instance_types = var.eks_instance_types
  node_group_desired_size = var.eks_node_desired_size
  node_group_min_size = var.eks_node_min_size
  node_group_max_size = var.eks_node_max_size

  depends_on = [module.vpc]
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  environment = var.environment

  # Тип БД
  use_aurora = var.use_aurora

  # Налаштування двигуна
  engine = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Сховище (тільки для RDS)
  allocated_storage = var.db_allocated_storage
  storage_type = var.db_storage_type
  storage_encrypted = var.db_storage_encrypted

  # Aurora специфічні параметри
  aurora_cluster_instances = var.aurora_cluster_instances

  # Мережа
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr]
  allowed_security_group_ids = []

  # Креденшели
  database_name = var.db_name
  master_username = var.db_master_username
  master_password = var.db_master_password

  # Доступність
  multi_az = var.db_multi_az
  publicly_accessible = var.db_publicly_accessible

  # Бекапи
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot = var.db_skip_final_snapshot

  # Моніторинг
  performance_insights_enabled = var.db_performance_insights_enabled
  enabled_cloudwatch_logs_exports = var.db_cloudwatch_logs_exports

  # Захист
  deletion_protection = var.db_deletion_protection

  tags = {
    Component = "Database"
  }

  depends_on = [module.vpc]
}

# Jenkins Module (CI/CD)
module "jenkins" {
  source = "./modules/jenkins"

  count = var.enable_jenkins ? 1 : 0

  namespace = var.jenkins_namespace
  service_type = var.jenkins_service_type
  admin_password = var.jenkins_admin_password

  depends_on = [module.eks]
}

# ArgoCD Module (GitOps)
module "argo_cd" {
  source = "./modules/argo_cd"

  count = var.enable_argocd ? 1 : 0

  namespace = var.argocd_namespace
  server_service_type = var.argocd_server_service_type
  app_name = var.argocd_app_name
  destination_namespace = var.argocd_app_namespace
  repo_url = var.argocd_repo_url
  chart_path = var.argocd_chart_path
  target_revision = var.argocd_target_revision

  depends_on = [module.eks]
}
