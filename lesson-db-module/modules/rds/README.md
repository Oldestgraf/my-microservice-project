# RDS/Aurora Terraform Module

Універсальний Terraform-модуль для створення AWS RDS або Aurora баз даних з автоматичним налаштуванням всієї необхідної інфраструктури.

## Зміст

- [Особливості](#особливості)
- [Приклади використання](#приклади-використання)
- [Змінні](#змінні)
- [Outputs](#outputs)
- [Як змінити налаштування](#як-змінити-налаштування)

## Особливості

-  **Умовна логіка**: Перемикання між RDS Instance та Aurora Cluster через `use_aurora`
-  **Автоматичне створення ресурсів**:
  - DB Subnet Group
  - Security Group з правилами доступу
  - Parameter Group з базовими параметрами (max_connections, log_statement, work_mem)
-  **Підтримка двигунів**: PostgreSQL та MySQL
-  **Гнучка конфігурація**: 30+ змінних для налаштування
-  **Безпека**: Encryption, private subnets, sensitive variables

## Приклади використання

### Приклад 1: RDS PostgreSQL Instance

```hcl
module "rds" {
  source = "./modules/rds"

  # Основні параметри
  project_name = "myapp"
  environment  = "dev"

  # Тип БД - звичайна RDS
  use_aurora = false

  # Налаштування двигуна
  engine = "postgres"
  engine_version = "16.1"
  instance_class = "db.t3.micro"

  # Сховище
  allocated_storage = 20
  storage_type = "gp3"
  storage_encrypted = true

  # Мережа
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  # Креденшели
  database_name = "mydb"
  master_username = "admin"
  master_password = var.db_password

  # Доступність
  multi_az = false

  # Бекапи
  backup_retention_period = 7
  skip_final_snapshot = true  # Для dev

  tags = {
    Environment = "Development"
  }
}
```

### Приклад 2: Aurora PostgreSQL Cluster

```hcl
module "aurora" {
  source = "./modules/rds"

  # Основні параметри
  project_name = "myapp"
  environment = "prod"

  # Тип БД - Aurora Cluster
  use_aurora = true

  # Налаштування двигуна
  engine = "aurora-postgresql"
  engine_version = "16.1"
  instance_class = "db.t3.medium"
  aurora_cluster_instances = 2  # 1 writer + 1 reader

  # Мережа
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  # Креденшели
  database_name = "mydb"
  master_username = "admin"
  master_password = var.db_password

  # Production налаштування
  backup_retention_period = 30
  skip_final_snapshot = false
  deletion_protection = true

  tags = {
    Environment = "Production"
  }
}
```

### Приклад 3: RDS MySQL Instance

```hcl
module "rds_mysql" {
  source = "./modules/rds"

  project_name = "myapp"
  environment = "dev"

  use_aurora = false

  # MySQL налаштування
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.small"

  # Кастомні параметри БД
  db_parameters = [
    {
      name = "max_connections"
      value = "200"
    },
    {
      name = "slow_query_log"
      value = "1"
    }
  ]

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnet_ids

  allowed_cidr_blocks = ["10.0.0.0/16"]

  database_name = "mydb"
  master_username = "admin"
  master_password = var.db_password
}
```

## Змінні

### Обов'язкові змінні

| Змінна | Тип | Опис |
|--------|-----|------|
| `project_name` | `string` | Назва проекту для іменування ресурсів |
| `vpc_id` | `string` | ID VPC для розгортання БД |
| `subnet_ids` | `list(string)` | Список ID підмереж для DB Subnet Group (мінімум 2) |
| `master_password` | `string` | Пароль головного користувача БД (sensitive) |

### Основні змінні

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `environment` | `string` | `"dev"` | Середовище розгортання (dev, staging, prod) |
| `use_aurora` | `bool` | `false` | **Ключова змінна**: `false` = RDS Instance, `true` = Aurora Cluster |
| `engine` | `string` | `"postgres"` | Тип двигуна: `postgres`, `mysql`, `aurora-postgresql`, `aurora-mysql` |
| `engine_version` | `string` | `"16.1"` | Версія двигуна БД |
| `instance_class` | `string` | `"db.t3.micro"` | Клас інстансу (db.t3.micro, db.t3.small, db.t3.medium, тощо) |
| `database_name` | `string` | `"mydb"` | Назва бази даних |
| `master_username` | `string` | `"admin"` | Ім'я головного користувача (sensitive) |

### Змінні сховища (тільки для RDS)

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `allocated_storage` | `number` | `20` | Об'єм сховища в GB |
| `storage_type` | `string` | `"gp3"` | Тип сховища: gp2, gp3, io1 |
| `storage_encrypted` | `bool` | `true` | Чи шифрувати сховище |

### Aurora специфічні змінні

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `aurora_cluster_instances` | `number` | `1` | Кількість інстансів в Aurora кластері |

### Мережеві змінні

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `allowed_cidr_blocks` | `list(string)` | `[]` | CIDR блоки з доступом до БД |
| `allowed_security_group_ids` | `list(string)` | `[]` | Security Group IDs з доступом до БД |
| `publicly_accessible` | `bool` | `false` | Чи має БД бути доступною публічно |

### Доступність

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `multi_az` | `bool` | `false` | Multi-AZ розгортання (тільки для RDS) |

### Бекапи

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `backup_retention_period` | `number` | `7` | Період зберігання бекапів (днів) |
| `backup_window` | `string` | `"03:00-04:00"` | Вікно для бекапів (UTC) |
| `maintenance_window` | `string` | `"mon:04:00-mon:05:00"` | Вікно для обслуговування (UTC) |
| `skip_final_snapshot` | `bool` | `false` | Пропускати фінальний snapshot |
| `final_snapshot_identifier_prefix` | `string` | `"final-snapshot"` | Префікс для snapshot |

### Додаткові параметри БД

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `db_parameters` | `list(object)` | `[]` | Додаткові параметри для Parameter Group |

Формат:
```hcl
db_parameters = [
  {
    name = "max_connections"
    value = "200"
  }
]
```

### Моніторинг

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `performance_insights_enabled` | `bool` | `false` | Performance Insights |
| `performance_insights_retention_period` | `number` | `7` | Період зберігання (днів) |
| `enabled_cloudwatch_logs_exports` | `list(string)` | `[]` | Типи логів для CloudWatch |

### Безпека

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `deletion_protection` | `bool` | `false` | Захист від видалення |

### Теги

| Змінна | Тип | За замовчуванням | Опис |
|--------|-----|------------------|------|
| `tags` | `map(string)` | `{}` | Додаткові теги для ресурсів |

## Outputs

### Загальні

| Output | Опис |
|--------|------|
| `db_type` | Тип БД (RDS або Aurora) |
| `engine` | Двигун БД |
| `endpoint` | Primary endpoint для підключення |
| `port` | Порт БД (5432 для Postgres, 3306 для MySQL) |
| `database_name` | Назва БД |
| `master_username` | Ім'я користувача (sensitive) |

### RDS специфічні

| Output | Опис |
|--------|------|
| `rds_instance_endpoint` | Endpoint RDS інстансу |
| `rds_instance_address` | Hostname RDS інстансу |

### Aurora специфічні

| Output | Опис |
|--------|------|
| `aurora_cluster_endpoint` | Writer endpoint |
| `aurora_cluster_reader_endpoint` | Reader endpoint |

### Мережа

| Output | Опис |
|--------|------|
| `security_group_id` | ID Security Group БД |
| `db_subnet_group_id` | ID DB Subnet Group |

## Як змінити налаштування

### Змінити тип БД з RDS на Aurora

```hcl
# Було
use_aurora = false
engine = "postgres"

# Стало
use_aurora = true
engine = "aurora-postgresql"
aurora_cluster_instances = 2
```

### Змінити engine (PostgreSQL → MySQL)

```hcl
# PostgreSQL
engine = "postgres"
engine_version = "16.1"

# MySQL
engine = "mysql"
engine_version = "8.0.35"
```

### Змінити клас інстансу

```hcl
# Development
instance_class = "db.t3.micro"   # 2 vCPU, 1 GB RAM, ~$12/міс

# Staging
instance_class = "db.t3.small"   # 2 vCPU, 2 GB RAM, ~$25/міс

# Production
instance_class = "db.t3.medium"  # 2 vCPU, 4 GB RAM, ~$50/міс
instance_class = "db.r6g.large"  # 2 vCPU, 16 GB RAM, ~$140/міс
```

### Увімкнути Multi-AZ

```hcl
multi_az = true  # Тільки для RDS, не для Aurora
```

Для Aurora - використовуйте кілька інстансів:
```hcl
use_aurora = true
aurora_cluster_instances = 2  # Автоматично розподіляються по AZ
```

### Додати кастомні параметри БД

```hcl
db_parameters = [
  {
    name = "max_connections"
    value = "200"
  },
  {
    name = "work_mem"
    value = "8192"  # 8MB в KB
  }
]
```

### Увімкнути моніторинг

```hcl
# Performance Insights
performance_insights_enabled = true
performance_insights_retention_period = 7

# CloudWatch Logs
enabled_cloudwatch_logs_exports = ["postgresql"]  # Для Postgres
# або
enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]  # Для MySQL
```

## Автоматично створювані ресурси

### 1. DB Subnet Group
Автоматично створюється з назвою: `{project_name}-{environment}-db-subnet-group`

### 2. Security Group
Автоматично створюється з назвою: `{project_name}-{environment}-db-sg`

**Правила:**
- Ingress: З `allowed_cidr_blocks` на порт БД
- Ingress: З `allowed_security_group_ids` на порт БД
- Egress: Весь трафік

### 3. Parameter Group

**Для PostgreSQL** (автоматичні параметри):
- `max_connections = 100`
- `log_statement = all`
- `work_mem = 4096` (4MB)

**Для MySQL** (автоматичні параметри):
- `max_connections = 100`
- `slow_query_log = 1`
- `long_query_time = 2`

## Приклади підключення

### PostgreSQL
```bash
# Отримати endpoint
terraform output endpoint

# Підключитися
psql -h <endpoint> -p 5432 -U admin -d mydb
```

### MySQL
```bash
# Отримати endpoint
terraform output endpoint

# Підключитися
mysql -h <endpoint> -P 3306 -u admin -p mydb
```

## Troubleshooting

### Помилка: "DB Subnet Group must contain at least 2 subnets"
Передайте мінімум 2 subnet_ids у різних AZ.

### Помилка: "Invalid instance class"
Перевірте що instance_class підходить для обраного engine та регіону.

### Помилка: "Parameter family not found"
Перевірте відповідність engine_version та parameter_group_family.

## Вартість

**RDS (us-east-1):**
- db.t3.micro: ~$12/міс
- db.t3.small: ~$25/міс
- db.t3.medium: ~$50/міс

**Aurora (us-east-1):**
- db.t3.medium (x1): ~$60/міс
- db.t3.medium (x2): ~$120/міс

Додатково: storage, backup, data transfer.
