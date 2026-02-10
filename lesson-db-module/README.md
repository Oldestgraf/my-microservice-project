# Terraform RDS Module - Домашнє завдання

Повний Terraform проєкт з модулем для AWS RDS/Aurora баз даних та підтримуючою інфраструктурою.

## Структура проєкту

```
lesson-db-module/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування S3 backend
├── outputs.tf               # Виводи ресурсів
├── variables.tf             # Змінні проєкту
├── terraform.tfvars.example # Приклад конфігурації
├── README.md                # Цей файл
├── HOMEWORK_SUMMARY.md      # Звіт про виконання ДЗ
├── .gitignore               # Git ignore
│
├── modules/                 # Каталог з модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── eks/                 # Модуль для EKS кластера
│   │   ├── eks.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── rds/                 # ГОЛОВНИЙ МОДУЛЬ (ДЗ)
│   │   ├── README.md
│   │   ├── variables.tf     # 30+ змінних
│   │   ├── outputs.tf       # Виводи
│   │   ├── shared.tf        # DB Subnet Group, Security Group, Parameter Groups
│   │   ├── rds.tf           # RDS Instance (use_aurora = false)
│   │   └── aurora.tf        # Aurora Cluster (use_aurora = true)
│   │
│   ├── jenkins/             # Модуль для Jenkins (опціонально)
│   │   ├── jenkins.tf
│   │   ├── variables.tf
│   │   ├── providers.tf
│   │   ├── values.yaml
│   │   └── outputs.tf
│   │
│   └── argo_cd/             # Модуль для ArgoCD (опціонально)
│       ├── argocd.tf
│       ├── variables.tf
│       ├── providers.tf
│       ├── values.yaml
│       └── outputs.tf
│
├── charts/                  # Helm чарти
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           └── hpa.yaml
│
└── Django/                  # Django додаток (опціонально)
    ├── app/
    ├── Dockerfile
    ├── Jenkinsfile
    └── docker-compose.yaml
```

## Швидкий старт

### Крок 1: Налаштування

```bash
# Скопіюйте приклад конфігурації
cp terraform.tfvars.example terraform.tfvars

# Відредагуйте terraform.tfvars
nano terraform.tfvars
```

**ВАЖЛИВО:** Змініть в `terraform.tfvars`:
- `terraform_state_bucket` - унікальна назва S3 bucket
- `db_master_password` - безпечний пароль

### Крок 2: Розгортання

```bash
# Ініціалізація
terraform init

# Перевірка (тільки RDS модуль за замовчуванням)
terraform plan

# Застосування
terraform apply

# Після успішного розгортання
terraform output
```

### Крок 3: Підключення до БД

```bash
# Отримати connection string
terraform output connection_string

# Підключитися до PostgreSQL
psql -h <endpoint> -p 5432 -U admin -d mydb
```

## Що створюється за замовчуванням

### Обов'язкові модулі (завжди створюються):

1. **S3 Backend** 
   - S3 bucket для Terraform state
   - DynamoDB для state locking

2. **VPC** 
   - VPC з 3 AZ
   - 3 публічні підмережі
   - 3 приватні підмережі
   - 3 підмережі для БД
   - Internet Gateway
   - NAT Gateway

3. **ECR** 
   - ECR репозиторій для Docker образів

4. **EKS** 
   - EKS кластер
   - Node Group

5. **RDS** 
   - RDS Instance АБО Aurora Cluster
   - DB Subnet Group
   - Security Group
   - Parameter Group

### Опціональні модулі (вимкнені за замовчуванням):

6. **Jenkins** (enable_jenkins = false)
7. **ArgoCD** (enable_argocd = false)

## Приклади використання

### Варіант 1: Тільки RDS (мінімальна конфігурація)

```hcl
# terraform.tfvars
use_aurora = false
db_engine = "postgres"
db_instance_class = "db.t3.micro"
db_skip_final_snapshot = true
deletion_protection  = false

# Jenkins та ArgoCD вимкнені
enable_jenkins = false
enable_argocd = false
```

**Вартість:** ~$12-25/міс (залежить від регіону)

### Варіант 2: Production Aurora Cluster

```hcl
# terraform.tfvars
use_aurora = true
db_engine = "aurora-postgresql"
db_instance_class = "db.t3.medium"
aurora_cluster_instances = 2
db_multi_az = true
db_skip_final_snapshot = false
db_deletion_protection = true

# Jenkins та ArgoCD вимкнені
enable_jenkins = false
enable_argocd  = false
```

**Вартість:** ~$120-200/міс

### Варіант 3: Повний стек (RDS + Jenkins + ArgoCD)

```hcl
# terraform.tfvars
use_aurora = false
db_engine  = "postgres"

# Увімкнути Jenkins та ArgoCD
enable_jenkins = true
enable_argocd  = true

jenkins_admin_password = "SecurePassword123!"
argocd_repo_url = "https://github.com/yourname/yourrepo.git"
```

**Вартість:** ~$100-300/міс (включаючи EKS)

## Налаштування

### Увімкнути Jenkins

```hcl
# В terraform.tfvars
enable_jenkins = true
jenkins_admin_password = "YourPassword"
```

### Увімкнути ArgoCD

```hcl
# В terraform.tfvars
enable_argocd = true
argocd_repo_url = "https://github.com/yourname/repo.git"
argocd_chart_path = "charts/django-app"
```

### Змінити тип БД з RDS на Aurora

```hcl
# В terraform.tfvars
use_aurora = true  # Було false
db_engine = "aurora-postgresql"
aurora_cluster_instances = 2
```

## Змінні конфігурації

### Обов'язкові змінні:

- `db_master_password` - Пароль БД (обов'язково змінити!)
- `terraform_state_bucket` - Унікальна назва S3 bucket

### Важливі змінні RDS:

| Змінна | За замовчуванням | Опис |
|--------|------------------|------|
| `use_aurora` | `false` | RDS або Aurora |
| `db_engine` | `"postgres"` | Тип БД |
| `db_instance_class` | `"db.t3.micro"` | Клас інстансу |
| `db_multi_az` | `false` | Multi-AZ |
| `aurora_cluster_instances` | `1` | К-сть інстансів Aurora |

Повний список змінних дивіться в `variables.tf` та `modules/rds/README.md`.

## Безпека

### Що вже налаштовано:

- Шифрування БД за замовчуванням
- Приватні підмережі для БД
- Security Groups з обмеженим доступом
- Sensitive змінні для паролів

### Що треба зробити:

1. **Змініть пароль БД** в `terraform.tfvars`
2. **Не комітьте** `terraform.tfvars` в git
3. **Змініть назву** S3 bucket на унікальну
4. **Для production:** встановіть `deletion_protection = true`

## Очищення ресурсів

```bash
terraform destroy
```

**УВАГА**: Це видалить всі ресурси включно з БД, EKS кластером тощо!

## Документація модулів

- **RDS Module**: `modules/rds/README.md` - Детальна документація RDS модуля
- **Звіт про ДЗ**: `HOMEWORK_SUMMARY.md` - Повний звіт про виконання завдання

## Troubleshooting

### Помилка: "Bucket already exists"

Змініть назву bucket в `terraform.tfvars`:
```hcl
terraform_state_bucket = "unique-name-12345"
```

### Помилка: "Insufficient capacity"

Змініть instance class:
```hcl
db_instance_class = "db.t3.small"  # Замість db.t3.micro
```

### БД створюється дуже довго

Це нормально. RDS створюється 5-10 хвилин, Aurora - 10-15 хвилин.

## Орієнтовна вартість

| Компонент | За місяць | Примітка |
|-----------|-----------|----------|
| VPC + NAT Gateway | $32 | NAT Gateway |
| ECR | $0.10/GB | За зберігання образів |
| EKS Cluster | $73 | Сам кластер |
| EKS Nodes (t3.medium x2) | $60 | Worker nodes |
| **RDS db.t3.micro** | **$12** | **Development** |
| **Aurora db.t3.medium x2** | **$120** | **Production** |
| S3 + DynamoDB | $1 | State storage |
| **ВСЬОГО (з RDS)** | **~$178** | Мінімум |
| **ВСЬОГО (з Aurora)** | **~$286** | Production |
