variable "aws_region" {
  type = string
  description = "AWS region"
  default = "us-west-2"
}

variable "eks_cluster_name" {
  type = string
  description = "Existing EKS cluster name (from lesson-7). Example: lesson-7-eks"
}

variable "ecr_repo_name" {
  type = string
  description = "ECR repository name for Django image"
  default = "lesson-8-9-django"
}

variable "app_repo_url" {
  type = string
  description = "THIS same repository URL (where Django code + Helm chart live). Example: https://github.com/<user>/<repo>.git"
}

variable "app_chart_path" {
  type = string
  description = "Path in THIS repo where the Helm chart lives"
  default = "charts/django-app"
}

variable "app_revision" {
  type = string
  description = "Branch Argo CD should track (same repo)"
  default = "main"
}

variable "jenkins_namespace" {
  type = string
  description = "Kubernetes namespace for Jenkins"
  default = "jenkins"
}

variable "argocd_namespace" {
  type = string
  description = "Kubernetes namespace for Argo CD"
  default = "argocd"
}

variable "django_namespace" {
  type = string
  description = "Namespace where Argo CD will deploy the Django app"
  default = "django"
}

variable "jenkins_admin_password" {
  type = string
  description = "Jenkins admin password (set your own)."
  sensitive = true
}

variable "jenkins_service_type" {
  type = string
  description = "Jenkins controller service type"
  default = "LoadBalancer"
}

variable "argocd_server_service_type" {
  type = string
  description = "Argo CD server service type"
  default = "LoadBalancer"
}
