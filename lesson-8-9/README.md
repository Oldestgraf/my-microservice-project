# Lesson-8-9: Jenkins + Helm + Terraform + Argo CD

## CI/CD flow
1) Jenkins збирає Docker image (Kaniko) з Dockerfile у цьому репо  
2) Jenkins пушить image в **ECR**  
3) Jenkins оновлює `charts/django-app/values.yaml` → `image.tag`  
4) Jenkins пушить коміт в `main` цього ж репо  
5) Argo CD (дивиться `main` цього ж репо) робить auto-sync в EKS

---

## 0) Передумови

Перевірити AWS creds:
```bash
aws sts get-caller-identity
```

Підключити kubectl до EKS (приклад):
```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
kubectl get nodes
```

---

## 1) Terraform (Jenkins + Argo CD + ECR)

### 1.1 backend.tf
Відкрити `lesson-8-9/backend.tf` і вписаит свій S3 bucket (зі state з lesson-5) і DynamoDB table.

### 1.2 terraform.tfvars
```bash
cd lesson-8-9
cp terraform.tfvars.example terraform.tfvars
```

Заповнити в `terraform.tfvars`:
- `eks_cluster_name` — назва кластера (lesson-7)
- `app_repo_url` — URL ЦЬОГО репо (`https://github.com/<you>/<repo>.git`)
- `jenkins_admin_password` — придумати пароль

### 1.3 Apply
```bash
terraform init
terraform plan
terraform apply
```

Отримаємо ECR URL:
```bash
terraform output -raw ecr_repository_url
```

---

## 2) Jenkinsfile (перед запуском job)

У корені репо є `Jenkinsfile`. Вставити реальний ECR URL в:
- `ECR_URL`

---

## 3) Jenkins і Argo CD URL/паролі

Jenkins:
```bash
kubectl get svc -n jenkins
cd lesson-8-9 && terraform output jenkins_admin_password
```

Argo CD:
```bash
kubectl get svc -n argocd
cd lesson-8-9 && terraform output argocd_initial_admin_password
```

---

## 4) Jenkins Credentials

Jenkins UI → Manage Jenkins → Credentials:

- `aws-access-key-id` (Secret text)
- `aws-secret-access-key` (Secret text)
- `repo-push-pat` (Secret text) — GitHub PAT з правом push у **це ж** repo (main)

---

## 5) Запуск pipeline

Створити Pipeline job (або Multibranch), який читає Jenkinsfile з цього репо і запустити build.

Очікувано:
- image зібрано та запушено в ECR
- values.yaml оновив `tag`
- коміт запушився в `main`
- Argo CD зробив auto-sync

---

## 6) Перевірка деплоя

```bash
kubectl get applications -n argocd
kubectl get pods -n django
kubectl get svc -n django
```

`django-service` має мати `EXTERNAL-IP`.

---

## Secrets vs ConfigMap

У chart:
- ConfigMap: DEBUG, DB_HOST/PORT/NAME/USER
- Secret: DB_PASSWORD, DJANGO_SECRET_KEY

⚠️ Не комітити реальні секрети!

---

## Cleanup

```bash
cd lesson-8-9
terraform destroy
```
