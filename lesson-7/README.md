# Lesson 7 — Helm + EKS + ECR (Django)

Домашнє завдання по темі **“Вивчення Helm”**.  


---

## 📁 Project structure

VPC та S3 backend були створені в lesson-5 і повторно не створюються. 
В lesson-7 вони використовуються як існуюча інфраструктура для EKS

```
lesson-7/
├── main.tf
├── backend.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── ecr/
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── eks/
│       ├── eks.tf
│       ├── variables.tf
│       └── outputs.tf
└── charts/
    └── django-app/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            └── hpa.yaml
```

---

## ⚙️ Prerequisites

### 1) AWS CLI
Перевірити, що AWS доступ працює:

```bash
aws sts get-caller-identity
```

### 2) Terraform
```bash
terraform -version
```

### 3) kubectl
```bash
kubectl version --client
```

### 4) Helm
```bash
helm version
```


---

## 1) Terraform: створення EKS + ECR

Перейти у папку `lesson-7`:

```bash
cd lesson-7
```

Ініціалізація:

```bash
terraform init
```

План:

```bash
terraform plan
```

Створення ресурсів:

```bash
terraform apply
```

---

## 2) Отримання ECR URL (репозиторій)

Після `terraform apply`:

```bash
terraform output
```

Або тільки URL:

```bash
terraform output -raw ecr_repository_url
```

Зручно зберегти в змінну:

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
echo $ECR_URL
```

Очікуваний формат (приклад):

```txt
123456789012.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django
```

---

## 3) Підключення kubectl до EKS

Оновити kubeconfig:

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
```

Перевірити, що ноди доступні:

```bash
kubectl get nodes
```

---

## 4) Push Docker image Django у ECR

### 4.1 Login в ECR
```bash
aws ecr get-login-password --region us-west-2 | \
docker login --username AWS --password-stdin $(echo $ECR_URL | cut -d'/' -f1)
```

### 4.2 Build image (використати Dockerfile з lesson-4)
Перейти в папку з Django проєктом (наприклад lesson-4) і зібрати image:

```bash
docker build -t django-app:latest .
```

### 4.3 Tag + Push
```bash
docker tag django-app:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

Перевірити images в ECR:

```bash
aws ecr describe-images --repository-name lesson-7-django --region us-west-2
```

---

## 5) Helm: перевірка шаблонів локально

Перед деплоєм можна подивитись, що Helm рендерить YAML:

```bash
helm template django-app ./charts/django-app
```

---

## 6) Helm: деплой у кластер

### Встановлення chart
```bash
helm install django-app ./charts/django-app \
  --set image.repository=$ECR_URL \
  --set image.tag=latest
```

Перевірити:

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

---

## 7) Доступ до застосунку (LoadBalancer)

Service створюється типу **LoadBalancer**. Отримати EXTERNAL-IP:

```bash
kubectl get svc django-service
```

Почекати поки з’явиться `EXTERNAL-IP`, потім відкрити його в браузері.

---

## 8) ConfigMap (env) — важливо

У chart є ConfigMap і він підключений у Deployment через:

```yaml
envFrom:
  - configMapRef:
      name: django-config
```

Змінні беруться з `values.yaml` секції `config`.

Подивитися configmap у кластері:

```bash
kubectl get configmap django-config -o yaml
```

---

## 9) HPA масштабування

HPA налаштовано:
- minReplicas: **2**
- maxReplicas: **6**
- scale при CPU > **70%**

Перевірити:

```bash
kubectl get hpa
```

---

## Cleanup

### Видалити Helm реліз:
```bash
helm uninstall django-app
```

### Видалити AWS ресурси:
```bash
terraform destroy
```

---