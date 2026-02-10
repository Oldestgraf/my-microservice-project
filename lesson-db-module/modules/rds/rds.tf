
resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = "${var.project_name}-${var.environment}-db"
  db_name = var.database_name
  engine = local.engine_name
  engine_version = var.engine_version

  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type = var.storage_type
  storage_encrypted = var.storage_encrypted

  username = var.master_username
  password = var.master_password

  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible = var.publicly_accessible
  port = local.db_port

  multi_az = var.multi_az
  availability_zone = var.multi_az ? null : data.aws_availability_zones.available.names[0]

  parameter_group_name = aws_db_parameter_group.rds[0].name

  backup_retention_period = var.backup_retention_period
  backup_window = var.backup_window
  maintenance_window = var.maintenance_window
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${var.project_name}-${var.environment}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = local.cloudwatch_logs
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  auto_minor_version_upgrade = true
  apply_immediately = false

  deletion_protection = var.deletion_protection

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-db"
      Environment = var.environment
      ManagedBy = "Terraform"
      Engine = local.engine_name
      Type = "RDS"
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password
    ]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
