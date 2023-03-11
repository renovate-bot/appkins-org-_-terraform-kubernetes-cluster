locals {
  extensions = {
    metrics = {
      labels = {
        tab  = "Metrics"
        icon = "fa-chart"
      }
      url = "https://github.com/argoproj-labs/argocd-extension-metrics/blob/main/manifests/extension.tar"
    }
    rollout = {
      labels = {}
      url    = "https://github.com/argoproj-labs/rollout-extension/releases/download/v0.2.1/extension.tar"
    }
  }
}
