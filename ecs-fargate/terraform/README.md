## Terraform Setup

Create a `terraform.tfvars` file with the following entry

```hcl
region                             = "us-east-1"
kong_cluster_control_plane         = "XXX.us.cp0.konghq.com:443"
kong_cluster_server_name           = "XXX.us.cp0.konghq.com"
kong_cluster_telemetry_endpoint    = "XXX.us.tp0.konghq.com:443"
kong_cluster_telemetry_server_name = "XXX.us.tp0.konghq.com"
availability_zones                 = ["us-east-1a", "us-east-1b"]

kong_cluster_cert_path     = "path_to_tls_crt/tls.crt"
kong_cluster_cert_key_path = "path_to_tls_key/tls.key"
initials                   = "RR"
```

The initials are used to create the required objects in AWS.

### running

Installing the DP
run `./create.sh`

#### Output 

You should see an output like this

```hcl
alb_dns_name = "RR-XXXX.us-east-1.elb.amazonaws.com"
ecs_cluster_id = "arn:aws:ecs:us-east-1:XXXXX:cluster/RR-ecs-cluster"
ecs_service_name = "RR-kong-gateway-service"
ecs_task_definition_arn = "arn:aws:ecs:us-east-1:XXXXX:task-definition/RR-kong-gateway-task:15"
kong_cluster_cert_arn = "arn:aws:secretsmanager:us-east-1:XXXXX:secret:RR-15-kong-cluster-cert-0zJHkw"
kong_cluster_cert_key_arn = "arn:aws:secretsmanager:us-east-1:XXXXX:secret:RR-15-kong-cluster-cert-key-WxqQ5u"
kong_cluster_cert_key_version_id = "terraform-XXXX"
kong_cluster_cert_version_id = "terraform-XXXX"
vpc_id = "vpc-XXXXX"
```

#### Testing

`curl  <alb_dns_name from above output>`

```json
{
  "message":"no Route matched with those values",
  "request_id":"7ff37d24ee159e3dae99721c17beae2d"
}
```

### Delete

`./destroy.sh`
