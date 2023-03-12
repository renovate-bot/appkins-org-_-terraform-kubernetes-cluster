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

resource "terraform_data" "cluster" {
  cluster_id = var.cluster_id

  connection {
    type     = "ssh"
    user     = var.ssh.user
    password = var.ssh.password
    host     = coalesce(var.ssh.host, self.public_ip)
  }

  provisioner "file" {
    content     = tls_self_signed_cert.ca.cert_pem
    destination = "/var/snap/microk8s/current/certs/dex-ca.crt"
  }

  provisioner "file" {
    content     = tls_self_signed_cert.ca.cert_pem
    destination = "/usr/local/ssl/ca.crt"
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply",
      "sudo snap install microk8s --classic --channel=1.26",
    ]
  }
}
