module "cert_manager" {
  # Create a certificate manager module
  source = "./modules/cert-manager"
  zone   = var.cloudflare.domain

  email      = var.cloudflare.email
  cloudflare = var.cloudflare
}

module "external-dns" {
  source = "./modules/external-dns"

  cluster_id = var.cluster_id

  cloudflare = var.cloudflare
  depends_on = [module.cert_manager]
}

module "monitoring" {
  source     = "./modules/monitoring"
  depends_on = [module.cert_manager]
}

module "ingress" {
  source = "./modules/ingress"

  external_ips = var.ingress.external_ips
  cloudflare   = var.cloudflare

  depends_on = [module.cert_manager]
}
