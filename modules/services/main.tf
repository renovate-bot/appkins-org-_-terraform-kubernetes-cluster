module "vault" {
  source = "./modules/vault"
}

module "argocd" {
  source = "./modules/argocd"

  github = var.github
}
