variable "cluster_id" {
  description = "Unique identifier for the cluster"
  type        = string
  default     = "microk8s"
}

variable "cloudflare" {
  type = object({
    api_key = string
    email   = string
    zone_id = string
    domain  = string
  })
  description = "(optional) describe your variable"
}

variable "ingress" {
  type = object({
    external_ips = list(string)
  })
  description = "Ingress configuration."
}
