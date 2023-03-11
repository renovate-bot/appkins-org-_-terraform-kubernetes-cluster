resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [yamlencode({
    server = {
      extensions = {
        enabled = true
      }
      metrics = {
        enabled = true
      }
      ingress = {
        enabled = true
        hosts   = ["argocd.${var.cluster_domain}"]
        tls     = [{ hosts = ["argocd.${var.cluster_domain}"] }]
        #https = true
        annotations = {
          "kubernetes.io/ingress.class"                  = "nginx"
          "ingress.kubernetes.io/force-ssl-redirect"     = "true"
          "nginx.ingress.kubernetes.io/ssl-passthrough"  = "true"
          "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
        }
        extraPaths = [
          {
            path     = "/extensions/metrics"
            pathType = "Prefix"
            backend = {
              service = {
                name = "argocd-o11y-server"
                port = {
                  number = 9003
                }
              }
            }
          },
          {
            path     = "/"
            pathType = "Prefix"
            backend = {
              service = {
                name = "argocd-server"
                port = {
                  number = 80
                }
              }
            }
          }
        ]
      }
    }
    repoServer = {
      volumeMounts = [{
        name      = "custom-tools"
        subPath   = "argocd-lovely-plugin"
        mountPath = "/usr/local/bin/argocd-lovely-plugin"
      }]
      volumes = [{
        name     = "custom-tools"
        emptyDir = {}
      }]
      initContainers = [{
        name            = "argocd-lovely-plugin-download"
        image           = "ghcr.io/crumbhole/argocd-lovely-plugin:stable"
        imagePullPolicy = "Always"
        volumeMounts = [{
          mountPath = "/custom-tools"
          name      = "custom-tools"
        }]
      }]
    }
    configs = {
      styles = <<-CSS
      .sidebar__logo {
        display: none;
      }
      .sidebar__version {
        display: none;
      }
      CSS
      cm = {
        url = "https://argocd.${var.cluster_domain}"

        /* "oidc.config" = <<-YAML
            name: GitHub
            issuer: https://github.com
            clientID: ${var.github.client_id}
            clientSecret: ${var.github.client_secret}
            requestedScopes:
            - user:email
            - read:org
            - read:user
            - read:public_key
            - read:repo_hook
            - repo
            - admin:repo_hook
            - admin:org_hook
            - write:repo_hook
            - write:org
            - write:public_key
            - write:discussion
            - delete_repo
          YAML */

        configManagementPlugins = <<-EOT
          - name: argocd-lovely-plugin
            generate:
              command: ["argocd-lovely-plugin"]
        EOT

        "dex.config" = <<-EOT
            connectors:
            - type: github
              id: github
              name: GitHub
              config:
                clientID: ${var.github.client_id}
                clientSecret: ${var.github.client_secret}
                orgs:
                - name: ${var.github.org}
          EOT
        /*
              redirectURI: https://argocd.${var.cluster_domain}/auth/callback
              teamNameField: slug
                userOrgMap:
                  ${var.github.org}: admin

                  */
      }
      secret = {
        extra = {
          "dex.github.clientSecret" = var.github.client_secret
        }
      }
    }
  })]

  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "rollouts" {
  name      = "argo-rollouts"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"

  values = [yamlencode({
    dashboard = {
      enabled = true
    }
  })]

  depends_on = [helm_release.argocd]
}

resource "helm_release" "workflows" {
  name      = "argo-workflows"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  version    = "0.22.8"

  values = [yamlencode({
    server = {
      extraArgs = ["--auth-mode=server"]
    }
  })]

  depends_on = [helm_release.argocd]
}

resource "helm_release" "apps" {
  name      = "argocd-apps"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"

  values = [yamlencode({
    extensions = [for k, v in local.extensions : {
      name             = "argocd-${k}-ext"
      namespace        = "argocd"
      additionalLabels = v.labels
      sources          = [{ web = { url = v.url } }]
    }]
  })]

  depends_on = [helm_release.rollouts]
}
