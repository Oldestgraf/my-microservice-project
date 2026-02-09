# Lesson-8-9: Jenkins + Helm + Terraform + Argo CD + Kaniko

## CI/CD flow
1) Jenkins збирає Docker image за допомогою **Kaniko** з Dockerfile проекту `lesson-4-django-docker`
2) Jenkins пушить image в **ECR** з тегом BUILD_NUMBER та latest
3) Jenkins оновлює `charts/django-app/values.yaml` → `image.tag` на новий BUILD_NUMBER
4) Jenkins комітить та пушить зміни в Git репозиторій
5) Argo CD (моніторить Git репозиторій) виявляє зміни та робить auto-sync в EKS

## Схема CI/CD

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CI/CD Pipeline Flow                         │
└─────────────────────────────────────────────────────────────────────┘

  Developer
      │
      │ git push
      ↓
  GitHub Repository (lesson-8-9 branch)
      │
      │ webhook / poll SCM
      ↓
┌─────────────────────────┐
│      Jenkins            │
│                         │
│  1. Checkout code       │ ← Jenkinsfile
│  2. Build image (Kaniko)│ ← Dockerfile from lesson-4-django-docker
│  3. Push to ECR        │ → AWS ECR (lesson-8-9-django:BUILD_NUMBER)
│  4. Update values.yaml │ → image.tag = BUILD_NUMBER
│  5. Git commit & push  │ → GitHub
└─────────────────────────┘
      │
      │ push updated values.yaml
      ↓
  GitHub Repository
      │
      │ auto-sync (polling)
      ↓
┌─────────────────────────┐
│      Argo CD            │
│                         │
│  - Detect changes       │
│  - Sync Helm chart      │
│  - Apply to cluster     │
└─────────────────────────┘
      │
      │ kubectl apply
      ↓
┌─────────────────────────┐
│   Kubernetes (EKS)      │
│                         │
│  - Update Deployment    │
│  - Rolling update       │
│  - HPA auto-scaling     │
└─────────────────────────┘
      │
      ↓
  Django Application Running
  (LoadBalancer Service)
```

## Структура проекту
```
lesson-8-9/
├── Jenkinsfile                    # Pipeline з етапами build/push/update-tag/commit
├── charts/
│   └── django-app/               # Helm chart для Django застосунку
│       ├── Chart.yaml
│       ├── values.yaml           # Конфігурація з image tag
│       └── templates/
├── modules/
│   ├── jenkins/
│   │   └── values.yaml           # Jenkins з Kaniko pod template
│   ├── argo_cd/
│   │   └── charts/argocd-apps/   # Автоматичне створення Applications
│   ├── ecr/
│   └── ...
├── setup-ecr-credentials.sh      # Скрипт для налаштування ECR credentials
└── JENKINS_SETUP.md              # Детальна інструкція з налаштування
```

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

## 2) Налаштування Jenkinsfile

`Jenkinsfile` знаходиться в `lesson-8-9/Jenkinsfile`. Перед запуском оновіть:

```groovy
environment {
    ECR_REGISTRY = '639747620745.dkr.ecr.us-west-2.amazonaws.com'  // ваш ECR registry
    ECR_REPOSITORY = 'lesson-8-9-django'                            // ваш ECR repository
    AWS_REGION = 'us-west-2'                                        // ваш AWS region
    GIT_CREDENTIALS_ID = 'github-credentials'                       // ID credentials в Jenkins
}
```

А також в stage 'Commit and Push Changes':
```groovy
git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/YOUR_USERNAME/YOUR_REPO.git
```

Детальніше: [JENKINS_SETUP.md](./JENKINS_SETUP.md)

---

## 3) Доступ до Jenkins і Argo CD

### Jenkins UI

1. Отримати URL:
```bash
kubectl get svc jenkins -n jenkins
# Знайдіть EXTERNAL-IP LoadBalancer
# URL: http://<EXTERNAL-IP>:8080
```

2. Отримати пароль адміністратора:
```bash
cd lesson-8-9
terraform output -raw jenkins_admin_password
```

3. Логін:
   - Username: `admin`
   - Password: (з output вище)

### Argo CD UI

1. Отримати URL:
```bash
kubectl get svc argocd-server -n argocd
# Знайдіть EXTERNAL-IP LoadBalancer
# URL: http://<EXTERNAL-IP>
```

2. Отримати пароль адміністратора:
```bash
cd lesson-8-9
terraform output -raw argocd_initial_admin_password
```

3. Логін:
   - Username: `admin`
   - Password: (з output вище)

---

## 4) Jenkins Credentials

### 4.1 ECR Credentials (для Kaniko)
Використовуйте helper скрипт для створення Kubernetes secret:
```bash
cd lesson-8-9
./setup-ecr-credentials.sh
```

Альтернативно, можна налаштувати IRSA (IAM Roles for Service Accounts) для автоматичного доступу до ECR.

### 4.2 GitHub Credentials (для Git push)
Jenkins UI → Manage Jenkins → Credentials:

- **ID**: `github-credentials`
- **Type**: Username with password
- **Username**: ваш GitHub username
- **Password**: GitHub Personal Access Token з правом `repo`

**Важливо**: Оновіть `Jenkinsfile` і замініть `YOUR_USERNAME/YOUR_REPO` на ваші дані!

---

## 5) Запуск Jenkins Pipeline

### 5.1 Створення Pipeline Job

1. Відкрийте Jenkins UI
2. New Item → Enter name: `django-app-build` → Pipeline → OK
3. Pipeline конфігурація:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: ваш Git репозиторій
   - **Branch**: `*/lesson-8-9` (або `*/main`)
   - **Script Path**: `lesson-8-9/Jenkinsfile`
4. Save

### 5.2 Перший Build

1. Натисніть "Build Now"
2. Перегляньте Console Output для моніторингу прогресу
3. Очікувані етапи:
   - ✅ Checkout - клонування коду
   - ✅ Build and Push Image - Kaniko збірка + push до ECR
   - ✅ Update Helm Chart Tag - оновлення values.yaml
   - ✅ Commit and Push Changes - git push

### 5.3 Перевірка Jenkins Job

**Успішний білд повинен:**
- Завершитися зі статусом SUCCESS (синій/зелений)
- Створити новий image в ECR з тегом = BUILD_NUMBER
- Оновити `charts/django-app/values.yaml` з новим тегом
- Створити коміт і запушити до Git

**Перевірка ECR:**
```bash
aws ecr describe-images \
  --repository-name lesson-8-9-django \
  --region us-west-2 \
  --query 'imageDetails[*].[imageTags[0],imagePushedAt]' \
  --output table
```

**Перевірка Git:**
```bash
git pull origin lesson-8-9
cat lesson-8-9/charts/django-app/values.yaml | grep "tag:"
# Повинен бути tag з номером останнього білду
```

---

## 6) Перевірка Argo CD Синхронізації

### 6.1 Перевірка Application

```bash
# Список всіх Applications
kubectl get applications -n argocd

# Детальна інформація про django-app
kubectl describe application django-app -n argocd
```

**Очікуваний статус:**
- **Sync Status**: Synced
- **Health Status**: Healthy
- **Revision**: останній коміт з Git

### 6.2 Argo CD UI

1. Відкрийте Argo CD UI
2. Знайдіть Application `django-app`
3. Перевірте:
   - ✅ Auto-sync enabled
   - ✅ Sync status: Synced
   - ✅ Health: Healthy
   - ✅ Revision відповідає останньому коміту
   - ✅ Image tag відповідає останньому білду Jenkins

### 6.3 Перевірка Deployment в Kubernetes

```bash
# Перевірка pods
kubectl get pods -n django
# Очікується: 2+ pods у статусі Running (згідно з HPA)

# Перевірка deployment
kubectl get deployment django-app -n django
# READY: 2/2 (або більше з HPA)

# Перевірка image tag
kubectl get deployment django-app -n django -o jsonpath='{.spec.template.spec.containers[0].image}'
# Повинен відповідати останньому білду

# Перевірка Service
kubectl get svc django-app -n django
# TYPE: LoadBalancer, EXTERNAL-IP повинен бути присутній
```

### 6.4 Перевірка застосунку

```bash
# Отримати URL застосунку
DJANGO_URL=$(kubectl get svc django-app -n django -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Django URL: http://$DJANGO_URL"

# Перевірка доступності
curl http://$DJANGO_URL
```

### 6.5 Моніторинг оновлення (Rolling Update)

```bash
# Подивитися історію rollout
kubectl rollout history deployment/django-app -n django

# Моніторинг статусу rollout в реальному часі
kubectl rollout status deployment/django-app -n django

# Подивитися events
kubectl get events -n django --sort-by='.lastTimestamp'
```

---

## Secrets vs ConfigMap

У chart:
- ConfigMap: DEBUG, DB_HOST/PORT/NAME/USER
- Secret: DB_PASSWORD, DJANGO_SECRET_KEY

⚠️ Не комітити реальні секрети!

---

## 7) Troubleshooting

### Jenkins Build Failed

**Problem**: Kaniko не може push до ECR
```bash
# Перевірка ECR credentials secret
kubectl get secret ecr-credentials -n jenkins
kubectl describe secret ecr-credentials -n jenkins

# Пересоздати secret
cd lesson-8-9
./setup-ecr-credentials.sh
```

**Problem**: Git push failed (authentication)
- Перевірте GitHub credentials в Jenkins (ID: `github-credentials`)
- Перевірте що Personal Access Token має права `repo`
- Перевірте URL репозиторію в Jenkinsfile

### Argo CD не синхронізує

**Problem**: Application показує "OutOfSync"
```bash
# Перевірка статусу
kubectl get application django-app -n argocd -o yaml

# Ручна синхронізація
kubectl patch application django-app -n argocd \
  --type merge \
  --patch '{"operation":{"sync":{}}}'
```

**Problem**: Application не створюється
```bash
# Перевірка argocd-apps helm release
helm list -n argocd
helm get values argocd-apps -n argocd

# Перевірка логів Argo CD
kubectl logs -n argocd deployment/argocd-application-controller
```

### Deployment Failed

**Problem**: Pods не запускаються (ImagePullBackOff)
```bash
# Перевірка events
kubectl describe pod <pod-name> -n django

# Перевірка image існує в ECR
aws ecr describe-images \
  --repository-name lesson-8-9-django \
  --region us-west-2
```

**Problem**: Service не має EXTERNAL-IP
```bash
# Перевірка service
kubectl describe svc django-app -n django

# Якщо pending, перевірте LoadBalancer controller
kubectl get pods -n kube-system | grep aws-load-balancer
```

### Загальні проблеми

**Перевірка підключення до EKS:**
```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
kubectl get nodes
```

**Перевірка всіх компонентів:**
```bash
# Jenkins
kubectl get pods -n jenkins
kubectl logs -n jenkins deployment/jenkins

# Argo CD
kubectl get pods -n argocd
kubectl logs -n argocd deployment/argocd-server

# Django app
kubectl get all -n django
```

---

## 8) Cleanup

**Видалення тільки застосунку:**
```bash
# Видалити Application в Argo CD
kubectl delete application django-app -n argocd
kubectl delete namespace django
```

**Повне видалення інфраструктури:**
```bash
cd lesson-8-9
terraform destroy
# Підтвердити: yes
```

**Примітка:** Terraform destroy видалить Jenkins, Argo CD та ECR репозиторій, але не видалить EKS кластер (створений в lesson-7).
