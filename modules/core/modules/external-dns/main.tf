resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "creds" {
  metadata {
    name      = "cloudflare-api-creds"
    namespace = "external-dns"
  }

  data = {
    api-key = var.cloudflare.api_key
    email   = var.cloudflare.email
  }

  type = "Opaque"
}

resource "helm_release" "external_dns" {
  name      = "external-dns"
  namespace = "external-dns"

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  values = [yamlencode(local.external_dns)]

  depends_on = [kubernetes_secret.creds]
}
