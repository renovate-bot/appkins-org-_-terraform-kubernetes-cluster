locals {
  public_ip = coalesce(var.public_ip, self.public_ip)

  dex_config = {
    volumes = [
      {
        name = "certs",
        secret = {
          secretName = "dex-certs"
        }
      }
    ],
    volumeMounts = [
      {
        name      = "certs",
        readOnly  = true,
        mountPath = "/certs"
      }
    ],
    https = {
      enabled = true
    }
    service = {
      type = "NodePort",
      ports = {
        https = {
          nodePort = 31000
        }
      }
    }
    config = {
      issuer = "https://${local.public_ip}:31000/dex",
      storage = {
        type = "memory"
      }
      web = {
        https   = "0.0.0.0:5554",
        tlsCert = "/certs/tls.crt",
        tlsKey  = "/certs/tls.key"
      }
      staticClients = [
        {
          name   = "Kubernetes",
          id     = "kubernetes",
          secret = "super-safe-client-secret",
          redirectURIs = [
            "http://localhost:8000"
          ]
        }
      ]
      enablePasswordDB = true,
      staticPasswords = [
        {
          email    = "admin@example.com",
          hash     = "$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W",
          username = "admin",
          userID   = "08a8684b-db88-4b73-90a9-3cd1661f5466"
        }
      ]
    }
  }
}
