variable "aws_region" {
  type = string
  description = "AWS region"
  default = "us-west-2"
}

# lesson-5 remote state (VPC outputs)
variable "lesson5_state_bucket" {
  type = string
  description = "S3 bucket where lesson-5 terraform.tfstate is stored"
}

variable "lesson5_state_key" {
  type = string
  description = "S3 key for lesson-5 terraform.tfstate"
}

variable "backend_dynamodb_table" {
  type = string
  description = "DynamoDB lock table name"
  default = "terraform-locks"
}

# EKS
variable "cluster_name" {
  type = string
  description = "EKS cluster name"
  default = "lesson-7-eks"
}

variable "kubernetes_version" {
  type = string
  description = "EKS Kubernetes version"
  default = "1.29"
}

# ECR
variable "ecr_name" {
  type = string
  description = "ECR repository name for Django image"
  default = "lesson-7-django"
}
