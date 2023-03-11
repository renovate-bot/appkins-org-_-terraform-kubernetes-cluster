locals {
  namespace = "ingress-nginx"

  cloudflare_config = {
    use-forwarded-headers = true
    proxy-real-ip-cidr    = "173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/12,172.64.0.0/13,131.0.72.0/22,2400:cb00::/32,2606:4700::/32,2803:f800::/32,2405:b500::/32,2405:8100::/32,2a06:98c0::/29,2c0f:f248::/32,10.0.0.0/8"
    use-proxy-protocol    = true
    forwarded-for-header  = "CF-Connecting-IP"
  }

  nginx = {
    controller = {
      //kind              = "DaemonSet"
      priorityClassName = "system-cluster-critical"
      metrics = {
        enabled = true
        prometheusRule = {
          enabled = false
        }
      }
      service = {
        externalIPs = ["192.168.50.75", "72.216.61.243"]
        #externalIps = var.external_ips
        type = "LoadBalancer"
        #loadBalancerIP = "72.216.61.243"
        annotations = {
          #"metallb.universe.tf/address-pool" = "production"
          "external-dns.alpha.kubernetes.io/hostname" = "${var.cloudflare.domain}."
        }
        /* nodePorts = {
          http  = 32080
          https = 32443
          tcp = {
            8080 = 32808
          }
        } */
      }
      /* hostPort = {
        enabled = true
        ports = { http = 80, https = 443, health = 10254 }
      } */
      ingressClassResource = {
        enabled = true
        default = true
      }
      extraArgs = {
        default-ssl-certificate = "${local.namespace}/ingress-nginx-wildcard-cert"
      }
      config = false ? local.cloudflare_config : {
        use-forwarded-headers = false
      }
    }
    defaultBackend = {
      enabled = true
    }
  }

  certificate = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "ingress-nginx-wildcard"
      namespace = local.namespace
    }
    spec = {
      dnsNames = [
        var.cloudflare.domain,
        "*.${var.cloudflare.domain}",
      ]
      issuerRef = {
        kind = "ClusterIssuer"
        name = "letsencrypt"
      }
      secretName = "ingress-nginx-wildcard-cert"
    }
  }
}
