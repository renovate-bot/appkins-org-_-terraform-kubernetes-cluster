variable "cluster_id" {
  description = "Unique identifier for the cluster"
  type        = string
  default     = "microk8s"
}

variable "organization" {
  description = "Organization name for the cluster"
  type        = string
  default     = "appkins"
}

variable "domain" {
  description = "Domain name for the cluster"
  type        = string
  default     = "appkins.net"
}

variable "public_ip" {
  description = "Public IP address for the cluster"
  type        = string
  default     = ""
}

variable "private_ip" {
  description = "Private IP address for the cluster"
  type        = string
  default     = ""
}
