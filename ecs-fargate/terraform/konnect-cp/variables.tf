variable "konnect_control_plane_name" {
  description = "Control plane name"
  type        = string
}

variable "cluster_type" {
  description = "Control plane cluster type"
  type        = string
}

variable "auth_type" {
  description = "Control plane auth type"
  type        = string
}

variable "personal_access_token" {
  description = "KPAT for konnect platform"
  type        = string
}

variable "server_url" {
  description = "Konnet API URL"
  type        = string
}
variable "kong_cluster_cert_path" {
  description = "Path to the Kong cluster certificate file"
  type        = string
}
