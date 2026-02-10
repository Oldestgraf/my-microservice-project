variable "namespace" { type = string default = "argocd" }
variable "server_service_type" { type = string default = "LoadBalancer" }

variable "app_name" { type = string default = "django-app" }
variable "destination_namespace" { type = string default = "django" }

variable "repo_url" { type = string }
variable "chart_path" { type = string default = "charts/django-app" }
variable "target_revision" { type = string default = "main" }
