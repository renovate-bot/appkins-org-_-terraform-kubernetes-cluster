variable "email" {
  type        = string
  description = "Email for use with letsencrypt."
}

variable "zone" {
  description = "DNS zone."
  type        = string
}

variable "cloudflare" {
  type = object({
    api_key = string
    zone_id = string
  })
  description = "Cloudflare API key and zone ID."
}
