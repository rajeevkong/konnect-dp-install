
output "kong_cluster_cert_arn" {
  value = aws_secretsmanager_secret.kong_cluster_cert.arn
}

output "kong_cluster_cert_version_id" {
  value = aws_secretsmanager_secret_version.kong_cluster_cert_version.version_id
}

output "kong_cluster_cert_key_arn" {
  value = aws_secretsmanager_secret.kong_cluster_cert_key.arn
}

output "kong_cluster_cert_key_version_id" {
  value = aws_secretsmanager_secret_version.kong_cluster_cert_key_version.version_id
}

