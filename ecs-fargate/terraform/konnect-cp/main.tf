
terraform {
  required_providers {
    konnect = {
      source = "kong/konnect"
    }
  }
}

resource "konnect_gateway_control_plane" "tfdemo" {
  name         = var.konnect_control_plane_name
  description  = "This is a sample description"
  cluster_type = var.cluster_type
  auth_type    = var.auth_type
}

resource "konnect_gateway_data_plane_client_certificate" "my_cert" {
  cert             = file(var.kong_cluster_cert_path)
  control_plane_id = konnect_gateway_control_plane.tfdemo.id
}


provider "konnect" {
  personal_access_token = var.personal_access_token
  server_url            = var.server_url
}

resource "konnect_gateway_service" "httpbin" {
  name             = "HTTPBin"
  protocol         = "https"
  host             = "httpbin.org"
  port             = 443
  path             = "/anything"
  control_plane_id = konnect_gateway_control_plane.tfdemo.id
}

resource "konnect_gateway_route" "hello" {
  methods = ["GET"]
  name    = "Anything"
  paths   = ["/anything"]

  strip_path = false

  control_plane_id = konnect_gateway_control_plane.tfdemo.id
  service = {
    id = konnect_gateway_service.httpbin.id
  }
}
