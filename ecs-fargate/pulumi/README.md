## Pulumi Setup

#### Create a Data Plane node

Create a [control plane](https://cloud.konghq.com/gateway-manager)

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

Update the `create.sh` file with the following entries

```python
pulumi config set initials YOUR_INITIALS
pulumi config set crtFilePath /path/to/crt/file
pulumi config set keyFilePath /path/to/key/file
pulumi config set awsRegion us-east-1

pulumi config set KONG_CLUSTER_CONTROL_PLANE AAA.us.cp0.konghq.com:443
pulumi config set KONG_CLUSTER_SERVER_NAME AAA.us.cp0.konghq.com
pulumi config set KONG_CLUSTER_TELEMETRY_ENDPOINT AAA.us.tp0.konghq.com:443
pulumi config set KONG_CLUSTER_TELEMETRY_SERVER_NAME AAA.us.tp0.konghq.com
```

The initials are used to create the required objects in AWS.

### running

Installing the DP
run `./create.sh`

#### Output

You should see an output like this

```json
{
  "crt_secret_arn": "arn:aws:secretsmanager:us-east-1:AWCSOMETHING:secret:INITIALS-crt-bmWkdF",
  "ecs_cluster_name": "INITIALS-cluster-f111111",
  "ecs_service_name": "INITIALS-service-b111111",
  "key_secret_arn": "arn:aws:secretsmanager:us-east-1:AWCSOMETHING:secret:INITIALS-key-aqhWw8",
  "listener_arn": "arn:aws:elasticloadbalancing:us-east-1:AWCSOMETHING:listener/app/INITIALS-lb-fde897b/29984c4ec6c69993/e632cc602e9ade01",
  "load_balancer_arn": "arn:aws:elasticloadbalancing:us-east-1:AWCSOMETHING:loadbalancer/app/INITIALS-lb-fde897b/29984c4ec6c69993",
  "load_balancer_dns": "INITIALS-lb-fde897b-222080631.us-east-1.elb.amazonaws.com",
  "log_group_name": "INITIALS-log-group-013ccfb",
  "nat_eip_id": "eipalloc-07c882cb9f01d54b7",
  "nat_gateway_id": "nat-028b10ef76505b7d3",
  "private_subnet_id": "subnet-bbbbbbbbbbbbbbbbb",
  "public_subnet1_id": "subnet-ccccccccccccccccc",
  "public_subnet2_id": "subnet-ddddddddddddddddd",
  "target_group_arn": "arn:aws:elasticloadbalancing:us-east-1:AWCSOMETHING:targetgroup/INITIALS-tg-5bfe3b6/73962fd91379ede0",
  "vpc_id": "vpc-eeeeeeeeeeeeeeee"
}
```

#### Testing

`curl  <load_balancer_dns from above output>`

```json
{
  "message":"no Route matched with those values",
  "request_id":"7ff37d24ee159e3dae99721c17beae2d"
}
```

### Delete

`./destroy.sh`
