variable "cluster_domain" {
  type        = string
  description = "The domain name of the cluster"
  default     = "appkins.net"
}

variable "github" {
  type = object({
    client_id     = string
    client_secret = string
    org           = string
  })
  description = "GitHub OAuth configuration"
}

variable "applications" {
  description = "tpl"
  type = list(
    object({
      additionalAnnotations = map(string)
      additionalLabels      = map(string)
      destination = object({
        namespace = string
        server    = optional(string, "https://kubernetes.default.svc")
      })
      finalizers = list(
        string
      )
      ignoreDifferences = list(
        object({
          group = string
          jsonPointers = list(
            string
          )
          kind = string
        })
      )
      info = list(
        object({
          name  = string
          value = string
        })
      )
      name      = string
      namespace = string
      project   = string
      source = object({
        directory = object({
          recurse = bool
        })
        path           = string
        repoURL        = string
        targetRevision = string
      })
      sources = list(
        object({
          chart          = string
          repoURL        = string
          targetRevision = string
        })
      )
      syncPolicy = object({
        automated = object({
          prune    = bool
          selfHeal = bool
        })
      })
    })
  )
  default = []
}
variable "applicationsets" {
  description = "tpl"
  type = list(
    object({
      additionalAnnotations = map(string)
      additionalLabels      = map(string)
      generators = list(
        object({
          git = object({
            directories = list(
              object({
                path = string
              })
            )
            repoURL  = string
            revision = string
          })
        })
      )
      name      = string
      namespace = string
      syncPolicy = object({
        preserveResourcesOnDeletion = bool
      })
      template = object({
        metadata = object({
          annotations = map(string)
          labels      = map(string)
          name        = string
        })
        spec = object({
          destination = object({
            namespace = string
            server    = string
          })
          ignoreDifferences = list(
            object({
              group = string
              jsonPointers = list(
                string
              )
              kind = string
            })
          )
          info = list(
            object({
              name  = string
              value = string
            })
          )
          project = string
          source = object({
            path           = string
            repoURL        = string
            targetRevision = string
          })
          syncPolicy = object({
            automated = object({
              prune    = bool
              selfHeal = bool
            })
          })
        })
      })
    })
  )
  default = []
}
variable "extensions" {
  description = "tpl"
  type = list(object({
    additionalAnnotations = optional(map(string))
    additionalLabels      = optional(map(string))
    name                  = string
    namespace             = string
    sources = list(
      object({
        git = optional(object({
          url = string
        }))
        web = optional(object({
          url = string
        }))
      })
    )
    })
  )
  default = []
}
variable "projects" {
  description = "tpl"
  type = list(
    object({
      additionalAnnotations    = map(string)
      additionalLabels         = map(string)
      clusterResourceBlacklist = optional(list(string), [])
      clusterResourceWhitelist = optional(list(string), [])
      description              = string
      destinations = list(
        object({
          namespace = string
          server    = string
        })
      )
      finalizers = list(
        string
      )
      name      = string
      namespace = string
      namespaceResourceBlacklist = list(
        object({
          group             = string
          kind              = string
          orphanedResources = optional(map(string))
          roles             = optional(list(string))
        })
      )
      namespaceResourceWhitelist = list(
        object({
          group = string
          kind  = string
        })
      )
      orphanedResources = map(string)
      roles             = optional(list(string), [])
      signatureKeys = list(
        object({
          keyID = string
        })
      )
      sourceNamespaces = list(
        string
      )
      sourceRepos = list(
        string
      )
      syncWindows = list(
        object({
          applications = list(
            string
          )
          duration   = string
          kind       = string
          manualSync = bool
          schedule   = string
        })
      )
    })
  )
  default = []
}
