# ============================================
# Backend Configuration
# ============================================
# За замовчуванням використовується локальний backend.
# Після створення S3 bucket та DynamoDB таблиці через модуль s3-backend,
# розкоментуйте блок нижче та виконайте terraform init -migrate-state

# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state-bucket-unique"  # Змініть на вашу назву
#     key            = "rds-homework/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

# ============================================
# Інструкції з налаштування remote backend:
# ============================================
#
# 1. Спочатку створіть S3 bucket та DynamoDB:
#    terraform init
#    terraform apply
#
# 2. Після створення S3 та DynamoDB:
#    - Розкоментуйте блок backend "s3" вище
#    - Змініть назву bucket на вашу (з terraform.tfvars)
#    - Виконайте: terraform init -migrate-state
#    - Підтвердіть міграцію state з локального в S3
#
# 3. State тепер зберігається в S3 з блокуванням через DynamoDB
#
# ВАЖЛИВО: Не видаляйте S3 bucket поки в ньому є state файли!
