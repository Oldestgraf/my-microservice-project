# Загальні змінні
variable "project_name" {
  description = "Назва проекту для іменування ресурсів"
  type = string
}

variable "environment" {
  description = "Середовище розгортання (dev, staging, prod)"
  type = string
  default = "dev"
}

variable "use_aurora" {
  description = "Використовувати Aurora Cluster (true) або звичайну RDS instance (false)"
  type= bool
  default= false
}

variable "engine" {
  description = "Тип двигуна БД (postgres, mysql, aurora-postgresql, aurora-mysql)"
  type = string
  default = "postgres"

  validation {
    condition = contains(["postgres", "mysql", "aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "Engine має бути: postgres, mysql, aurora-postgresql або aurora-mysql."
  }
}

variable "engine_version" {
  description = "Версія двигуна БД"
  type = string
  default = "16.1"
}

variable "instance_class" {
  description = "Клас інстансу БД (наприклад, db.t3.micro, db.t3.small)"
  type = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Об'єм сховища в GB (тільки для RDS, не для Aurora)"
  type = number
  default = 20
}

variable "storage_type" {
  description = "Тип сховища (gp2, gp3, io1)"
  type = string
  default = "gp3"
}

variable "storage_encrypted" {
  description = "Чи шифрувати сховище БД"
  type = bool
  default = true
}

variable "multi_az" {
  description = "Чи розгортати БД в кількох зонах доступності"
  type = bool
  default = false
}

variable "publicly_accessible" {
  description = "Чи має БД бути доступною публічно"
  type = bool
  default = false
}

variable "aurora_cluster_instances" {
  description = "Кількість інстансів в Aurora кластері"
  type = number
  default = 1
}

variable "database_name" {
  description = "Назва бази даних"
  type = string
  default = "mydb"
}

variable "master_username" {
  description = "Ім'я головного користувача БД"
  type = string
  default = "admin"
  sensitive = true
}

variable "master_password" {
  description = "Пароль головного користувача БД"
  type = string
  sensitive = true
}

variable "vpc_id" {
  description = "ID VPC для розгортання БД"
  type = string
}

variable "subnet_ids" {
  description = "Список ID підмереж для DB Subnet Group"
  type = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR блоки, які мають доступ до БД"
  type = list(string)
  default = []
}

variable "allowed_security_group_ids" {
  description = "Security Group ID, які мають доступ до БД"
  type = list(string)
  default = []
}

variable "backup_retention_period" {
  description = "Період зберігання бекапів (днів)"
  type = number
  default = 7
}

variable "backup_window" {
  description = "Вікно для створення бекапів (UTC)"
  type = string
  default = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Вікно для обслуговування (UTC)"
  type = string
  default = "mon:04:00-mon:05:00"
}

variable "skip_final_snapshot" {
  description = "Чи пропускати фінальний snapshot при видаленні"
  type = bool
  default = false
}

variable "final_snapshot_identifier_prefix" {
  description = "Префікс для фінального snapshot"
  type = string
  default = "final-snapshot"
}

variable "db_parameters" {
  description = "Додаткові параметри для DB Parameter Group"
  type = list(object({
    name = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Додаткові теги для ресурсів"
  type = map(string)
  default = {}
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Список типів логів для експорту в CloudWatch"
  type = list(string)
  default = []
}

variable "performance_insights_enabled" {
  description = "Чи ввімкнути Performance Insights"
  type = bool
  default = false
}

variable "performance_insights_retention_period" {
  description = "Період зберігання Performance Insights (днів)"
  type = number
  default = 7
}

variable "deletion_protection" {
  description = "Чи ввімкнути захист від видалення"
  type = bool
  default = false
}
