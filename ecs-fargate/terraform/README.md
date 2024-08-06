## Terraform Setup

#### Get Konnect Token

Generate a [konnect token](https://docs.konghq.com/konnect/gateway-manager/declarative-config/#generate-a-personal-access-token).

We will need the token for the `personal_access_token`.

Create a `terraform.tfvars` file with the following entry

```hcl
region                     = "us-east-1"
availability_zones         = ["us-east-1a", "us-east-1b"]
initials                   = "<INITIALS>-CP" # Initials to create objects on AWS
konnect_control_plane_name = "my-terraform-cp"
cluster_type               = "CLUSTER_TYPE_HYBRID"
auth_type                  = "pinned_client_certs"
personal_access_token      = "kpat_from_konnect"
server_url                 = "https://us.api.konghq.com" # this will be "https://au.api.konghq.com" or "https://eu.api.konghq.com"
kong_cluster_cert_path     = "./.local/tls.crt"
kong_cluster_cert_key_path = "./.local/tls.key"
```

The initials are used to create the required objects in AWS.

### running

Installing the DP
run `./create.sh`

#### Output

You should see an output like this

```hcl
alb_dns_name = "<INITIALS>-XXXX.us-east-1.elb.amazonaws.com"
ecs_cluster_id = "arn:aws:ecs:us-east-1:XXXXX:cluster/<INITIALS>-ecs-cluster"
ecs_service_name = "<INITIALS>-kong-gateway-service"
ecs_task_definition_arn = "arn:aws:ecs:us-east-1:XXXXX:task-definition/<INITIALS>-kong-gateway-task:15"
kong_cluster_cert_arn = "arn:aws:secretsmanager:us-east-1:XXXXX:secret:<INITIALS>-kong-cluster-cert-0zJHkw"
kong_cluster_cert_key_arn = "arn:aws:secretsmanager:us-east-1:XXXXX:secret:<INITIALS>-kong-cluster-cert-key-WxqQ5u"
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

### Change

- [*] Adding ability to add control plane and deploy a dataplane on ECS Fargate in Terraform
