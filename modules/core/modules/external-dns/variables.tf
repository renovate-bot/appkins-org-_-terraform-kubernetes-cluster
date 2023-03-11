variable "cluster_id" {
  type        = string
  description = "Unique identifier for the cluster"
  default     = null
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
