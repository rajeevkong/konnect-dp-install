provider "aws" {
  region = var.region
}

module "konnect" {
  source                     = "./konnect-cp"
  kong_cluster_cert_path     = var.kong_cluster_cert_path
  konnect_control_plane_name = var.konnect_control_plane_name
  cluster_type               = var.cluster_type
  auth_type                  = var.auth_type
  personal_access_token      = var.personal_access_token
  server_url                 = var.server_url
}


module "vpc" {
  source               = "./vpc"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = var.availability_zones
  initials             = var.initials
}

module "secrets" {
  source                     = "./secrets"
  kong_cluster_cert_path     = var.kong_cluster_cert_path
  kong_cluster_cert_key_path = var.kong_cluster_cert_key_path
  initials                   = var.initials
}

module "ecs" {
  source                             = "./ecs"
  region                             = var.region
  vpc_id                             = module.vpc.vpc_id
  public_subnet_ids                  = module.vpc.public_subnet_ids
  private_subnet_ids                 = module.vpc.private_subnet_ids
  kong_cluster_control_plane         = "${replace(module.konnect.control_plane_endpoint, "/(^https://)|(/$)/", "")}:443" #var.kong_cluster_control_plane
  kong_cluster_server_name           = replace(module.konnect.control_plane_endpoint, "/(^https://)|(/$)/", "")          #var.kong_cluster_server_name
  kong_cluster_cert_arn              = module.secrets.kong_cluster_cert_arn
  kong_cluster_cert_key_arn          = module.secrets.kong_cluster_cert_key_arn
  kong_cluster_telemetry_endpoint    = "${replace(module.konnect.telemetry_endpoint, "/(^https://)|(/$)/", "")}:443" #var.kong_cluster_telemetry_endpoint
  kong_cluster_telemetry_server_name = replace(module.konnect.telemetry_endpoint, "/(^https://)|(/$)/", "")          #var.kong_cluster_telemetry_server_name
  initials                           = var.initials
}
