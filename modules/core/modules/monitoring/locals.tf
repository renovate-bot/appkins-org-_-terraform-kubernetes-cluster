locals {
  prometheus_stack = {
    alertmanager = {
      alertmanagerSpec = {
        priorityClassName = "system-cluster-critical"
      }
    }
    prometheus = {
      prometheusSpec = {
        priorityClassName = "system-cluster-critical"
      }
    }
    grafana = {
      ingress = {
        enabled          = true
        hosts            = ["grafana.appkins.net"]
        tls              = [{ hosts = ["grafana.appkins.net"] }]
        ingressClassName = "nginx"
      }
      sidecar = {
        dashboards = {
          labelValue = "true"
        }
      }
    }
    prometheusOperator = {
      admissionWebhooks = {
        certManager = {
          enabled = true
        }
      }
    }
  }

  tempo = {

  }

  loki = {
    monitoring = {
      dashboards = {
        labels = {
          grafana_dashboard = "true"
        }
      }
    }
    write = {
      replicas = 1
    }
    read = {
      replicas = 1
    }
    /* gateway = {
      service = {
        type = "NodePort"
        nodePort = 33080
      }
    } */
  }
}
