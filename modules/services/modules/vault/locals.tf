locals {
  vault = {
    ui = {
      enabled = true
    }
    server = {
      ingress = {
        enabled = true
        hosts   = [{ host = "vault.appkins.net" }]
        tls     = [{ hosts = ["vault.appkins.net"] }]
        https   = true
      }
    }
    global = {
      serverTelemetry = {
        prometheusOperator = true
      }
    }
  }
}
