resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  namespace = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  atomic     = true
  timeout    = 300

  values = [yamlencode(local.cert_manager)]
}

resource "kubernetes_secret" "credentials" {
  metadata {
    name      = "provider-credentials"
    namespace = "cert-manager"
  }

  data = {
    api-key = var.cloudflare.api_key
    email   = var.email
  }

  type = "Opaque"
}

resource "kubectl_manifest" "issuer" {
  yaml_body = yamlencode(local.issuer)
  wait      = true
  depends_on = [
    kubernetes_secret.credentials, helm_release.cert_manager
  ]
}
