resource "kubernetes_namespace" "nginx" {
  metadata {
    name = local.namespace
  }
}

resource "kubectl_manifest" "certificate" {
  yaml_body = yamlencode(local.certificate)
  wait      = true
}

resource "kubernetes_config_map" "dashboard" {
  #for_each = { for v in fileset(path.module, "dashboards/*.json"): regex("dashboards/(.+).json", v)[0] => v }
  metadata {
    name      = "ingress-dashboards"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = true
    }
  }

  data = { for v in fileset(path.module, "dashboards/*.json") : regex("^dashboards/(.*)", v)[0] => file("${path.module}/${v}") }
}

resource "helm_release" "nginx" {
  name      = "ingress-nginx"
  namespace = local.namespace

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  timeout    = 3000

  values = [yamlencode(local.nginx)]

  depends_on = [
    kubectl_manifest.certificate
  ]
}
