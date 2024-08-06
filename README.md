## Konnect Dataplane installation

### Installing a Konnect Data plane on ECS Fargate

#### A note of caution

> This is by no means production grade code so please treat it as dev and experimental only. If you feel this can be improved then please feel free to contribute

> This script will create a VPC, NAT GW etc so please tailor this accordingly.

I am using [saml2aws](https://github.com/Versent/saml2aws). The [create (for terraform)](./ecs-fargate/terraform/create.sh) and [destroy](./ecs-fargate/terraform/destroy.sh) scripts assumes you have 2FA enabled. So please make changes accordingly.

One thing you will need is the SSO URL for configuring sam2aws.

> If you know a better way to do run the scripts in an enterprise context then please do share.

### Kong Konnect Setup

I am assuming that if you are here you know how to register with Konnect, create a control plane. If you dont then please [Sign up](https://konghq.com/products/kong-konnect/register) on Konnect

1. [Terraform ECS-Fargate](./ecs-fargate/terraform/README.md). The terraform provider for Konnect is available [here](https://docs.konghq.com/konnect/reference/terraform/).
1. [Pulumi ECS-Fargate](./ecs-fargate/pulumi/README.md)
