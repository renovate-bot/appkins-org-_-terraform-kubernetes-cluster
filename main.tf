module "core" {
  source = "./modules/core"

  cluster_id = var.cluster_id
  cloudflare = var.cloudflare
  ingress    = var.ingress
}

module "services" {
  source = "./modules/services"

  cluster_id = var.cluster_id
  cloudflare = var.cloudflare
  ingress    = var.ingress
  github     = var.github
}
