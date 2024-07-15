## Konnect Dataplane installation

### Installing a Konnect Data plane on ECS Fargate

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



1. [Terraform ECS-Fargate](./ecs-fargate/terraform/README.md)
1. [Pulumi ECS-Fargate](./ecs-fargate/pulumi/README.md)

