
resource "aws_secretsmanager_secret" "kong_cluster_cert" {
  name = "${var.initials}-15-kong-cluster-cert"
}

resource "aws_secretsmanager_secret_version" "kong_cluster_cert_version" {
  secret_id     = aws_secretsmanager_secret.kong_cluster_cert.id
  secret_string = file(var.kong_cluster_cert_path)
}

resource "aws_secretsmanager_secret" "kong_cluster_cert_key" {
  name = "${var.initials}-15-kong-cluster-cert-key"
}

resource "aws_secretsmanager_secret_version" "kong_cluster_cert_key_version" {
  secret_id     = aws_secretsmanager_secret.kong_cluster_cert_key.id
  secret_string = file(var.kong_cluster_cert_key_path)
}

