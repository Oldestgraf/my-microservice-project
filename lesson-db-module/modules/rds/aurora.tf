
resource "aws_rds_cluster" "aurora" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.project_name}-${var.environment}-aurora-cluster"
  engine = local.engine_name
  engine_version = var.engine_version
  engine_mode = "provisioned"
  database_name = var.database_name

  master_username = var.master_username
  master_password = var.master_password

  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  port = local.db_port

  availability_zones = slice(data.aws_availability_zones.available.names, 0, min(3, length(data.aws_availability_zones.available.names)))

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.backup_window
  preferred_maintenance_window = var.maintenance_window
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${var.project_name}-${var.environment}-aurora-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = local.cloudwatch_logs

  apply_immediately = false

  deletion_protection = var.deletion_protection

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-aurora-cluster"
      Environment = var.environment
      ManagedBy = "Terraform"
      Engine = local.engine_name
      Type = "Aurora"
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      master_password,
      availability_zones
    ]
  }
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count = var.use_aurora ? var.aurora_cluster_instances : 0

  identifier = "${var.project_name}-${var.environment}-aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora[0].id

  instance_class = var.instance_class
  engine = aws_rds_cluster.aurora[0].engine
  engine_version = aws_rds_cluster.aurora[0].engine_version

  publicly_accessible = var.publicly_accessible

  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  auto_minor_version_upgrade = true
  apply_immediately = false

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-aurora-instance-${count.index + 1}"
      Environment = var.environment
      ManagedBy = "Terraform"
      ClusterRole = count.index == 0 ? "writer" : "reader"
      Type = "Aurora Instance"
    },
    var.tags
  )
}
