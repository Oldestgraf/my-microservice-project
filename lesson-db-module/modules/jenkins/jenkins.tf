resource "kubernetes_namespace" "ns" {
  metadata { name = var.namespace }
}

resource "helm_release" "jenkins" {
  name = "jenkins"
  namespace = kubernetes_namespace.ns.metadata[0].name
  repository = "https://charts.jenkins.io"
  chart = "jenkins"

  values = [templatefile("${path.module}/values.yaml", {
    service_type = var.service_type
  })]

  set { name = "controller.adminUser" value = "admin" }

  set_sensitive {
    name = "controller.adminPassword"
    value = var.admin_password
  }
}
