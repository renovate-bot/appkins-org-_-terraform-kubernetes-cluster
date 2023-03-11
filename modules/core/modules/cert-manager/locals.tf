locals {
  cert_manager = {
    global = {
      priorityClassName = "system-cluster-critical"
      leaderElection = {
        namespace = "cert-manager"
      }
    }
    webhook = {
      serviceType = "NodePort"
    }
    resources = {
      requests = {
        cpu    = "10m"
        memory = "32Mi"
      }
    }
    installCRDs = true
  }

  env = "prod"

  letsencrypt = {
    prod    = "https://acme-v02.api.letsencrypt.org/directory"
    staging = "https://acme-staging-v02.api.letsencrypt.org/directory"
  }

  issuer = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt"
    }
    spec = {
      acme = {
        server = local.letsencrypt[local.env]
        email  = var.email
        privateKeySecretRef = {
          name = "issuer-letsencrypt-privatekey"
        }

        solvers = [{
          selector = {
            dnsZones = [var.zone]
          }
          dns01 = {
            cloudflare = {
              apiKeySecretRef = {
                key  = "api-key"
                name = "provider-credentials"
              }
              email = var.email
            }
          }
        }]
      }
    }
  }
}
