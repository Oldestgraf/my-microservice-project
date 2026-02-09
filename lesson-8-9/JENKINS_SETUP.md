# Jenkins CI/CD Setup для Lesson 8-9

## Огляд

Цей урок демонструє налаштування Jenkins для автоматичної збірки Docker образів за допомогою Kaniko та деплою в Kubernetes через ArgoCD.

## Компоненти

1. **Jenkinsfile** - Pipeline з етапами:
   - Checkout коду
   - Build та Push образу до ECR (Kaniko)
   - Оновлення тегу в Helm values
   - Commit та Push змін до Git

2. **Jenkins Helm Chart** - з налаштованим Kaniko pod template
3. **Django App Helm Chart** - для деплою застосунку

## Передумови

1. EKS кластер налаштований
2. ECR репозиторій створений
3. Jenkins встановлений через Terraform/Helm
4. ArgoCD встановлений і налаштований

## Налаштування

### 1. Створення ECR Credentials Secret

Jenkins потребує доступу до ECR для push образів. Створіть secret з AWS credentials:

```bash
# Отримайте ECR login token
aws ecr get-login-password --region us-west-2 > /tmp/ecr-password

# Створіть Docker config
cat <<EOF > /tmp/config.json
{
  "auths": {
    "639747620745.dkr.ecr.us-west-2.amazonaws.com": {
      "auth": "$(echo -n AWS:$(cat /tmp/ecr-password) | base64)"
    }
  }
}
EOF

# Створіть Kubernetes secret
kubectl create secret generic ecr-credentials \
  --from-file=config.json=/tmp/config.json \
  -n jenkins

# Видаліть тимчасові файли
rm /tmp/ecr-password /tmp/config.json
```

### 2. Створення GitHub Credentials

Для commit та push змін до Git:

1. Згенеруйте GitHub Personal Access Token:
   - Перейдіть до GitHub Settings → Developer settings → Personal access tokens
   - Створіть токен з правами `repo` (повний доступ до репозиторіїв)

2. Додайте credentials в Jenkins:
   - Jenkins → Manage Jenkins → Credentials
   - Add Credentials → Username with password
   - Username: ваш GitHub username
   - Password: згенерований токен
   - ID: `github-credentials`

### 3. Оновлення Jenkinsfile

Відредагуйте `Jenkinsfile` і замініть:
- `YOUR_USERNAME` на ваш GitHub username
- `YOUR_REPO` на назву вашого репозиторію

```groovy
git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/YOUR_USERNAME/YOUR_REPO.git
```

### 4. Створення Jenkins Pipeline Job

1. Відкрийте Jenkins UI
2. Створіть новий Pipeline job:
   - New Item → Pipeline
   - Name: `django-app-build`

3. Налаштуйте Pipeline:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: ваш Git репозиторій
   - Script Path: `lesson-8-9/Jenkinsfile`

4. Налаштуйте Build Triggers (опціонально):
   - Poll SCM: `H/5 * * * *` (кожні 5 хвилин)
   - Або налаштуйте GitHub webhook

## Структура Pipeline

### Stage 1: Checkout
Клонує репозиторій з вихідним кодом.

### Stage 2: Build and Push Image
- Використовує Kaniko для збірки Docker образу
- Тегує образ з BUILD_NUMBER та latest
- Push до ECR репозиторію
- Використовує кеш для прискорення збірки

### Stage 3: Update Helm Chart Tag
- Використовує `yq` для оновлення `image.tag` в `values.yaml`
- Встановлює тег з номером білду

### Stage 4: Commit and Push Changes
- Конфігурує Git user
- Комітить зміни в `values.yaml`
- Push змін до Git репозиторію

## Kaniko Pod Template

Jenkins налаштований з pod template для Kaniko:

- **kaniko container**: для збірки та push образів
- **git container**: для Git операцій
- **Volume mount**: ECR credentials для аутентифікації

## ArgoCD Integration

Після того як Jenkins оновить тег в `values.yaml` та запушить зміни:

1. ArgoCD автоматично визначить зміни в Git
2. Синхронізує нову версію з кластером
3. Kubernetes задеплоїть нову версію образу

## Перевірка Pipeline

1. Запустіть білд в Jenkins
2. Перевірте логи кожного етапу
3. Перевірте, що новий образ з'явився в ECR:
   ```bash
   aws ecr describe-images --repository-name lesson-8-9-django --region us-west-2
   ```
4. Перевірте, що `values.yaml` оновлено в Git
5. Перевірте синхронізацію в ArgoCD UI

## Troubleshooting

### ECR Authentication Failed
- Перевірте, що secret `ecr-credentials` існує в namespace `jenkins`
- Перевірте, що IAM роль для EKS має доступ до ECR

### Git Push Failed
- Перевірте GitHub credentials в Jenkins
- Перевірте, що токен має права `repo`
- Перевірте URL репозиторію в Jenkinsfile

### Kaniko Build Failed
- Перевірте логи kaniko контейнера
- Перевірте Dockerfile на помилки
- Перевірте ресурси pod (CPU/Memory limits)

### ArgoCD не синхронізує
- Перевірте налаштування Auto-Sync в ArgoCD Application
- Перевірте шлях до Helm chart
- Перевірте ArgoCD репозиторій credentials

## Наступні кроки

1. Налаштуйте GitHub webhooks для автоматичного тригеру білдів
2. Додайте етап запуску тестів перед збіркою
3. Налаштуйте нотифікації (Slack, Email)
4. Додайте multi-branch pipeline для різних гілок
5. Налаштуйте PR перевірку перед мерджем