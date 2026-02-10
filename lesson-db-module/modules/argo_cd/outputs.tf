data "kubernetes_secret" "argocd_admin" {
  metadata {
    name = "argocd-initial-admin-secret"
    namespace = var.namespace
  }
  depends_on = [helm_release.argocd]
}

output "initial_admin_password" {
  value = data.kubernetes_secret.argocd_admin.data["password"]
  sensitive = true
}
