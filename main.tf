resource "terraform_data" "cluster" {
  cluster_id = var.cluster_id

  connection {
    type     = "ssh"
    user     = var.ssh.user
    password = var.ssh.password
    host     = coalesce(var.ssh.host, self.public_ip)
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply",
      "consul join ${aws_instance.web.private_ip}",
    ]
  }
}

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
