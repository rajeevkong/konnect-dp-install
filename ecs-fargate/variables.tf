
variable "region" {
  description = "The AWS region"
  type        = string
}

variable "kong_cluster_control_plane" {
  description = "The control plane endpoint for Kong"
  type        = string
}

variable "kong_cluster_server_name" {
  description = "The server name for Kong control plane"
  type        = string
}

variable "kong_cluster_telemetry_endpoint" {
  description = "The telemetry endpoint for Kong"
  type        = string
}

variable "kong_cluster_telemetry_server_name" {
  description = "The telemetry server name for Kong"
  type        = string
}

variable "availability_zones" {
  description = "The availability zones in the region"
  type        = list(string)
}

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

