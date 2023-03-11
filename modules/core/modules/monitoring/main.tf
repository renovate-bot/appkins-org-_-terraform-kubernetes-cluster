resource "helm_release" "prometheus_stack" {
  name      = "prometheus-stack"
  namespace = "monitoring"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [yamlencode(local.prometheus_stack)]
}

resource "helm_release" "tempo" {
  name      = "tempo"
  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"

  values = [yamlencode(local.tempo)]
}

resource "helm_release" "loki" {
  name      = "loki"
  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"

  values = [yamlencode(local.loki)]
}
