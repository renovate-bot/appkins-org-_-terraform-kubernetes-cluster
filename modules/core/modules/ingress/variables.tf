variable "external_ips" {
  type        = list(string)
  description = "List of external IPs"
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
