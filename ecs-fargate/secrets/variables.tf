variable "kong_cluster_cert_path" {
  description = "Path to the Kong cluster certificate file"
  type        = string
}

variable "kong_cluster_cert_key_path" {
  description = "Path to the Kong cluster certificate key file"
  type        = string
}
variable "initials" {
  description = "Initials to prepend to the names of all created resources"
  type        = string
}