resource "terraform_data" "install" {
  input = local.ca

  connection {
    type        = "ssh"
    user        = var.ssh.user
    private_key = var.ssh.private_key
    host        = coalesce(var.ssh.host, self.public_ip)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo snap install microk8s --classic --channel=1.26",
    ]
  }
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name = "kube-ca"
  }

  is_ca_certificate = true

  validity_period_hours = 87600

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

resource "terraform_data" "ca" {
  input = local.ca

  connection {
    type        = "ssh"
    user        = var.ssh.user
    private_key = var.ssh.private_key
    host        = coalesce(var.ssh.host, self.public_ip)
  }

  provisioner "file" {
    content     = local.ca.crt
    destination = "/usr/local/ssl/ca.crt"
  }

  provisioner "file" {
    content     = local.ca.key
    destination = "/usr/local/ssl/ca.key"
  }

  provisioner "remote-exec" {
    inline = [
      "microk8s refresh-certs /usr/local/ssl"
    ]
  }
}
