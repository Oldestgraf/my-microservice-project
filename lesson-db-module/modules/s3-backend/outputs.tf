output "s3_bucket_id" {
  description = "ID S3 bucket"
  value = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN S3 bucket"
  value = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Назва DynamoDB таблиці"
  value = aws_dynamodb_table.terraform_state_lock.name
}

output "dynamodb_table_arn" {
  description = "ARN DynamoDB таблиці"
  value = aws_dynamodb_table.terraform_state_lock.arn
}
