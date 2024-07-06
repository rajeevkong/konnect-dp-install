output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "subnet_ids" {
#   value = module.vpc.subnet_ids
# }
#
output "ecs_cluster_id" {
  value = module.ecs.ecs_cluster_id
}

output "ecs_task_definition_arn" {
  value = module.ecs.ecs_task_definition_arn
}

output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "kong_cluster_cert_arn" {
  value = module.secrets.kong_cluster_cert_arn
}

output "kong_cluster_cert_version_id" {
  value = module.secrets.kong_cluster_cert_version_id
}

output "kong_cluster_cert_key_arn" {
  value = module.secrets.kong_cluster_cert_key_arn
}

output "kong_cluster_cert_key_version_id" {
  value = module.secrets.kong_cluster_cert_key_version_id
}
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.ecs.alb_dns_name
}
