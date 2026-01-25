terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Забираємо VPC/subnets з lesson-5 (та сама мережа)
data "terraform_remote_state" "lesson5" {
  backend = "s3"

  config = {
    bucket = var.lesson5_state_bucket
    key = var.lesson5_state_key
    region = var.aws_region
    dynamodb_table = var.backend_dynamodb_table
    encrypt = true
  }
}

# ECR repo для Django
module "ecr" {
  source = "./modules/ecr"
  ecr_name = var.ecr_name
  scan_on_push = true
}

# EKS в існуючій VPC (lesson-5)
module "eks" {
  source = "./modules/eks"

  cluster_name = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id = data.terraform_remote_state.lesson5.outputs.vpc_id
  private_subnets = data.terraform_remote_state.lesson5.outputs.private_subnet_ids

  node_group_desired_size = 2
  node_group_min_size = 2
  node_group_max_size = 6

  instance_types = ["t3.medium"]
}
