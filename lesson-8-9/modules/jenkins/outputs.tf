data "kubernetes_secret" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.namespace
  }
  depends_on = [helm_release.jenkins]
}

output "admin_password" {
  value     = data.kubernetes_secret.jenkins.data["jenkins-admin-password"]
  sensitive = true
}
