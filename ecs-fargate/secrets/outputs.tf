
output "kong_cluster_cert_arn" {
  description = "ARN of the Kong cluster certificate secret"
  value       = aws_secretsmanager_secret.kong_cluster_cert.arn
}

output "kong_cluster_cert_version_id" {
  description = "Version ID of the Kong cluster certificate secret"
  value       = aws_secretsmanager_secret_version.kong_cluster_cert_version.version_id
}

output "kong_cluster_cert_key_arn" {
  description = "ARN of the Kong cluster certificate key secret"
  value       = aws_secretsmanager_secret.kong_cluster_cert_key.arn
}

output "kong_cluster_cert_key_version_id" {
  description = "Version ID of the Kong cluster certificate key secret"
  value       = aws_secretsmanager_secret_version.kong_cluster_cert_key_version.version_id
}

