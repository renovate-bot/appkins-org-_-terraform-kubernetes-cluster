locals {
  configuration = {
    zone-id-filter = var.cloudflare.zone_id
    #fqdn-template = "{{.Name}}.appkins.net"
  }

  flags = {
    cloudflare-proxied = true
  }

  compiled_args = concat(
    [for k, v in local.configuration : "--${k}=${v}"],
    [for k, v in local.flags : "--${k}" if v]
  )

  external_dns = {
    domainFilters = ["appkins.net"]
    provider      = "cloudflare"

    txtOwnerId = var.cluster_id
    registry   = "txt"
    policy     = "sync"

    env = [
      {
        name = "CF_API_KEY"
        valueFrom = {
          secretKeyRef = {
            key  = "api-key"
            name = "cloudflare-api-creds"
          }
        }
      },
      {
        name = "CF_API_EMAIL"
        valueFrom = {
          secretKeyRef = {
            key  = "email"
            name = "cloudflare-api-creds"
          }
        }
      },
    ]
    extraArgs         = local.compiled_args
    fullnameOverride  = "external-dns"
    nameOverride      = "external-dns"
    priorityClassName = "system-cluster-critical"
    sources = [
      "ingress",
      "service"
    ]
  }
}
