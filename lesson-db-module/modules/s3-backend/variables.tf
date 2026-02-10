variable "bucket_name" {
  description = "Назва S3 bucket для Terraform state"
  type = string
}

variable "dynamodb_table_name" {
  description = "Назва DynamoDB таблиці для state locking"
  type = string
  default = "terraform-state-lock"
}

variable "state_retention_days" {
  description = "Кількість днів зберігання старих версій state"
  type = number
  default = 90
}

variable "enable_point_in_time_recovery" {
  description = "Увімкнути Point-in-Time Recovery для DynamoDB"
  type = bool
  default = false
}

variable "tags" {
  description = "Додаткові теги"
  type = map(string)
  default = {}
}
