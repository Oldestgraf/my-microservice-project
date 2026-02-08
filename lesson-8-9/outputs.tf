output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL for the Django image"
}

output "jenkins_admin_password" {
  value       = module.jenkins.admin_password
  sensitive   = true
  description = "Jenkins admin password (from Helm secret)"
}

output "argocd_initial_admin_password" {
  value       = module.argo_cd.initial_admin_password
  sensitive   = true
  description = "Argo CD initial admin password (from secret)"
}
