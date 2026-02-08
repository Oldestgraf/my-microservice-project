module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_repo_name
  scan_on_push = true
}

module "jenkins" {
  source = "./modules/jenkins"

  namespace      = var.jenkins_namespace
  service_type   = var.jenkins_service_type
  admin_password = var.jenkins_admin_password
}

module "argo_cd" {
  source = "./modules/argo_cd"

  namespace             = var.argocd_namespace
  server_service_type   = var.argocd_server_service_type

  app_name              = "django-app"
  destination_namespace = var.django_namespace

  repo_url              = var.app_repo_url
  chart_path            = var.app_chart_path
  target_revision       = var.app_revision
}
