
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "kong_cluster_cert_arn" {
  description = "The ARN of the KONG cluster certificate secret"
  type        = string
}

variable "kong_cluster_cert_version_id" {
  description = "The version ID of the KONG cluster certificate secret"
  type        = string
}

variable "kong_cluster_cert_key_arn" {
  description = "The ARN of the KONG cluster certificate key secret"
  type        = string
}

variable "kong_cluster_cert_key_version_id" {
  description = "The version ID of the KONG cluster certificate key secret"
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

variable "initials" {
  description = "Initials to prepend to the names of all created resources"
  type        = string
}

