
output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.main.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.main.name
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.ecs_lb.dns_name
}
