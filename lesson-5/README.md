# Lesson 5 — Terraform IaC (S3 Backend + VPC + ECR)

Це домашнє завдання по темі **IaC (Terraform)**.  
Проєкт створює AWS інфраструктуру з використанням модулів Terraform:

✅ **S3 + DynamoDB** для збереження Terraform state та блокування (locking)  
✅ **VPC** з 3 публічними та 3 приватними підмережами + IGW + NAT Gateway + Route Tables  
✅ **ECR** репозиторій для зберігання Docker-образів (image scan on push)

---

## 📁 Project structure

```
lesson-5/                   
├── main.tf                 Головний файл для підключення модулів
├── backend.tf              Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf              Загальне виведення ресурсів
├── modules/                Каталог з усіма модулями
│   ├── s3-backend/         Модуль для S3 та DynamoDB
│   │   ├── s3.tf           Створення S3-бакета
│   │   ├── dynamodb.tf     Створення DynamoDB
│   │   ├── variables.tf    Змінні для S3
│   │   └── outputs.tf      Виведення інформації про S3 та DynamoDB
│   ├── vpc/                Модуль для VPC
│   │   ├── vpc.tf          Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf       Налаштування маршрутизації
│   │   ├── variables.tf    Змінні для VPC
│   │   └── outputs.tf      Виведення інформації про VPC
│   └── ecr/                Модуль для ECR
│       ├── ecr.tf          Створення ECR репозиторію
│       ├── variables.tf    Змінні для ECR
│       └── outputs.tf      Виведення URL репозиторію ECR
└── README.md               Документація проєкту
```

---

## ✅ What is created

### 1) S3 backend + DynamoDB locking (`modules/s3-backend`)
Створює:
- **S3 bucket** для збереження `terraform.tfstate`
- **Versioning enabled** (збереження історії стейтів)
- **Encryption enabled** (AES256)
- **Public access blocked**
- **DynamoDB table** для locking (щоб уникнути одночасних змін)

Outputs:
- `s3_bucket_name`
- `dynamodb_table_name`

---

### 2) VPC network infrastructure (`modules/vpc`)
Створює:
- **VPC** з CIDR блоком
- **3 public subnets**
- **3 private subnets**
- **Internet Gateway** для public підмереж
- **NAT Gateway** для private підмереж
- **Route tables** та асоціації маршрутів

Outputs:
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `nat_gateway_id`

---

### 3) ECR repository (`modules/ecr`)
Створює:
- **ECR repository**
- **Image scan on push** (сканування при пуші)
- **Policy access** для доступу поточного AWS аккаунта

Outputs:
- `repository_url`

---


## 🚀 How to run

⚠️ **Важливий момент:** backend на S3 не може працювати одразу,  
тому що bucket і DynamoDB ще НЕ створені на першому запуску.

---

### ✅ Step 1: First init без backend (local state)

Перейди у папку `lesson-5/`:

```bash
cd lesson-5
```

І виконай:

```bash
terraform init -backend=false
terraform plan
terraform apply
```

Після цього Terraform створить:
- S3 bucket
- DynamoDB table
- VPC
- ECR

---

### ✅ Step 2: Enable backend (S3 + DynamoDB) and migrate state

Після першого apply можна використовувати бекенд з `backend.tf`.

Виконай команду:

```bash
terraform init -reconfigure -migrate-state
```

Це:
- підключить backend S3
- перенесе локальний state у S3
- включить locking через DynamoDB

---

### ✅ Step 3: Standard workflow

Після міграції стейту працює стандартний цикл:

```bash
terraform plan
terraform apply
```

---

## 🧹 Destroy infrastructure

Щоб видалити всі ресурси:

```bash
terraform destroy
```

---