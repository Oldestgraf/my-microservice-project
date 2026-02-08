resource "kubernetes_namespace" "ns" {
  metadata { name = var.namespace }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.ns.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [templatefile("${path.module}/values.yaml", {
    server_service_type = var.server_service_type
  })]
}

resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  namespace = kubernetes_namespace.ns.metadata[0].name
  chart     = "${path.module}/charts/argocd-apps"

  values = [templatefile("${path.module}/charts/argocd-apps/values.yaml", {
    app_name              = var.app_name
    destination_namespace = var.destination_namespace
    repo_url              = var.repo_url
    chart_path            = var.chart_path
    target_revision       = var.target_revision
  })]

  depends_on = [helm_release.argocd]
}
