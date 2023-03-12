resource "kubernetes_namespace" "agones" {
  metadata {
    name = "agones-system"
  }
}

resource "helm_release" "agones" {
  name       = "agones"
  repository = "https://agones.dev/chart/stable"
  chart      = "agones"
  version    = var.chart_version
  namespace  = "agones-system"


  set {
    name  = "agones.crds.CleanupOnDelete"
    value = true
  }

  set {
    name  = "agones.ping.udp.expose"
    value = false
  }

  set {
    name  = "agones.allocator.install"
    value = false
  }

  depends_on = [
    kubernetes_namespace.agones
  ]

}
