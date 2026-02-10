
resource "aws_db_subnet_group" "this" {
  name = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
      Environment = var.environment
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_security_group" "db" {
  name = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for ${var.use_aurora ? "Aurora" : "RDS"} database"
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-db-sg"
      Environment = var.environment
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "db_ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type = "ingress"
  from_port = local.db_port
  to_port = local.db_port
  protocol = "tcp"
  cidr_blocks = var.allowed_cidr_blocks
  security_group_id = aws_security_group.db.id
  description = "Allow database access from specified CIDR blocks"
}

resource "aws_security_group_rule" "db_ingress_sg" {
  count = length(var.allowed_security_group_ids)

  type = "ingress"
  from_port = local.db_port
  to_port = local.db_port
  protocol = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id = aws_security_group.db.id
  description = "Allow database access from security group ${var.allowed_security_group_ids[count.index]}"
}

resource "aws_security_group_rule" "db_egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db.id
  description = "Allow all outbound traffic"
}

resource "aws_db_parameter_group" "rds" {
  count = var.use_aurora ? 0 : 1

  name = "${var.project_name}-${var.environment}-${local.engine_family}-params"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = local.default_db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-${local.engine_family}-params"
      Environment = var.environment
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count = var.use_aurora ? 1 : 0

  name = "${var.project_name}-${var.environment}-${local.engine_family}-cluster-params"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = local.default_db_parameters
    content {
      name = parameter.value.name
      value = parameter.value.value
    }
  }

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-${local.engine_family}-cluster-params"
      Environment = var.environment
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

locals {
  db_port = (
    can(regex("postgres", var.engine)) ? 5432 :
    can(regex("mysql", var.engine)) ? 3306 :
    5432
  )

  engine_name = var.use_aurora ? (
    var.engine == "postgres" || var.engine == "aurora-postgresql" ? "aurora-postgresql" : "aurora-mysql"
    ) : (
    var.engine == "aurora-postgresql" ? "postgres" :
    var.engine == "aurora-mysql" ? "mysql" :
    var.engine
  )

  engine_family = (
    can(regex("postgres|aurora-postgresql", var.engine)) ? "postgres" : "mysql"
  )

  parameter_group_family = (
    var.use_aurora ? (
      can(regex("postgres|aurora-postgresql", var.engine)) ? "aurora-postgresql16" : "aurora-mysql8.0"
      ) : (
      can(regex("postgres", var.engine)) ? "postgres16" : "mysql8.0"
    )
  )

  default_db_parameters = (
    can(regex("postgres", var.engine)) ? [
      {
        name = "max_connections"
        value = "100"
      },
      {
        name = "log_statement"
        value = "all"
      },
      {
        name = "work_mem"
        value = "4096"  # 4MB в KB
      }
    ] : [
      {
        name = "max_connections"
        value = "100"
      },
      {
        name = "slow_query_log"
        value = "1"
      },
      {
        name = "long_query_time"
        value = "2"
      }
    ]
  )

  cloudwatch_logs = var.enabled_cloudwatch_logs_exports != [] ? var.enabled_cloudwatch_logs_exports : (
    can(regex("postgres", var.engine)) ? ["postgresql"] : ["error", "general", "slowquery"]
  )
}
