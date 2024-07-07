## Installing a Konnect Data plane on ECS Fargate

#### A note of caution

> This is by no means production grade code so please treat it as dev and experimental only. If you feel this can be improved then please feel free to contribute

> This script will create a VPC, NAT GW etc so please tailor this accordingly. 

I am using [saml2aws](https://github.com/Versent/saml2aws). The [create](./ecs-fargate/create.sh) and [destroy](./ecs-fargate/destroy.sh) scripts assumes you have 2FA enabled. So please make changes accordingly. 

One thing you will need is the SSO URL for configuring sam2aws. 

> If you know a better way to do run the scripts in an enterprise context then please do share.

### Kong Konnect Setup

I am assuming that if you are here you know how to register with Konnect, create a control plane. If you dont then please the following two links

1. [Sign up](https://konghq.com/products/kong-konnect/register) on Konnect
2. Create a [control plane](https://cloud.konghq.com/gateway-manager)

#### Create a Data Plane node

- Navigate to the control plane for which you want to add the data plane.
- Navigate to `Data Plane Nodes` on the left hand navigation.
- Click on `New Data Plane Node`.
- Select the `gateway version`.
- Select the `Platform`. Pick any one. Make a note of the following fields

    ```yml
      cluster_control_plane: XXX.us.cp0.konghq.com:443
      cluster_server_name: XXX.us.cp0.konghq.com
      cluster_telemetry_endpoint: XXX.us.tp0.konghq.com:443
      cluster_telemetry_server_name: XXX.us.tp0.konghq.com
    ```

- Save the certifcates (crt, key) to a local folder under someplace safe.

### Terraform Setup

Create a `terraform.tfvars` file under `ecs-fargate` folder with the following entry

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
