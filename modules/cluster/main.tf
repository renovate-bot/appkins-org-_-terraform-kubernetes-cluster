resource "tls_private_key" "dex" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "example" {
  private_key_pem = tls_private_key.dex.private_key_pem

  dns_names    = [var.domain]
  ip_addresses = [var.public_ip, var.private_ip]

  subject {
    common_name  = var.domain
    organization = var.organization
  }
}

resource "tls_self_signed_cert" "dex" {
  private_key_pem = tls_private_key.dex.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_locally_signed_cert" "dex" {
  cert_request_pem   = file("cert_request.pem")
  ca_private_key_pem = tls_private_key.dex.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.dex.cert_pem

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
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

  provisioner "remote-exec" {
    inline = [
      "puppet apply",
      "microk8s kubectl create secret tls dex-certs --cert=ssl/tls.crt --key=ssl/tls.key",
    ]
  }
}
