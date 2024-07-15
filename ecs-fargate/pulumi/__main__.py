import json
import pulumi
import pulumi_aws as aws

# Get config values
config = pulumi.Config()
initials = config.require("initials")
crt_file_path = config.require("crtFilePath")
key_file_path = config.require("keyFilePath")
aws_region = config.require("awsRegion")  # Get the AWS region from Pulumi config

# Environment variables from config
kong_cluster_control_plane = config.require("KONG_CLUSTER_CONTROL_PLANE")
kong_cluster_server_name = config.require("KONG_CLUSTER_SERVER_NAME")
kong_cluster_telemetry_endpoint = config.require("KONG_CLUSTER_TELEMETRY_ENDPOINT")
kong_cluster_telemetry_server_name = config.require(
    "KONG_CLUSTER_TELEMETRY_SERVER_NAME"
)

# Set the AWS region for Pulumi
aws.config.region = aws_region

# Read the cert and key files
with open(crt_file_path, "r") as crt_file:
    crt_content = crt_file.read()

with open(key_file_path, "r") as key_file:
    key_content = key_file.read()

# Create a new VPC
vpc = aws.ec2.Vpc(
    f"{initials}-vpc",
    cidr_block="10.0.0.0/16",
    enable_dns_support=True,
    enable_dns_hostnames=True,
)

# Create public subnets in two different Availability Zones
public_subnet1 = aws.ec2.Subnet(
    f"{initials}-public-subnet1",
    vpc_id=vpc.id,
    cidr_block="10.0.1.0/24",
    availability_zone=f"{aws_region}a",
    map_public_ip_on_launch=True,
)

public_subnet2 = aws.ec2.Subnet(
    f"{initials}-public-subnet2",
    vpc_id=vpc.id,
    cidr_block="10.0.2.0/24",
    availability_zone=f"{aws_region}b",
    map_public_ip_on_launch=True,
)

# Create a private subnet
private_subnet = aws.ec2.Subnet(
    f"{initials}-private-subnet",
    vpc_id=vpc.id,
    cidr_block="10.0.3.0/24",
)

# Create an internet gateway
internet_gateway = aws.ec2.InternetGateway(
    f"{initials}-igw",
    vpc_id=vpc.id,
)

# Create an Elastic IP for the NAT Gateway
eip = aws.ec2.Eip(f"{initials}-nat-eip", domain="vpc")

# Create a NAT Gateway
nat_gateway = aws.ec2.NatGateway(
    f"{initials}-nat-gateway",
    allocation_id=eip.id,
    subnet_id=public_subnet1.id,
)

# Create a route table for the public subnets
public_route_table = aws.ec2.RouteTable(
    f"{initials}-public-rt",
    vpc_id=vpc.id,
    routes=[
        aws.ec2.RouteTableRouteArgs(
            cidr_block="0.0.0.0/0",
            gateway_id=internet_gateway.id,
        )
    ],
)

# Associate the route table with the public subnets
public_route_table_association1 = aws.ec2.RouteTableAssociation(
    f"{initials}-public-rt-association1",
    subnet_id=public_subnet1.id,
    route_table_id=public_route_table.id,
)

public_route_table_association2 = aws.ec2.RouteTableAssociation(
    f"{initials}-public-rt-association2",
    subnet_id=public_subnet2.id,
    route_table_id=public_route_table.id,
)

# Create a route table for the private subnet
private_route_table = aws.ec2.RouteTable(
    f"{initials}-private-rt",
    vpc_id=vpc.id,
    routes=[
        aws.ec2.RouteTableRouteArgs(
            cidr_block="0.0.0.0/0",
            nat_gateway_id=nat_gateway.id,
        )
    ],
)

# Associate the route table with the private subnet
private_route_table_association = aws.ec2.RouteTableAssociation(
    f"{initials}-private-rt-association",
    subnet_id=private_subnet.id,
    route_table_id=private_route_table.id,
)

# Create a security group for the load balancer
lb_security_group = aws.ec2.SecurityGroup(
    f"{initials}-lb-sg",
    vpc_id=vpc.id,
    description="Security group for load balancer",
    ingress=[
        aws.ec2.SecurityGroupIngressArgs(
            protocol="tcp",
            from_port=80,
            to_port=80,
            cidr_blocks=["0.0.0.0/0"],
        ),
        aws.ec2.SecurityGroupIngressArgs(
            protocol="tcp",
            from_port=443,
            to_port=443,
            cidr_blocks=["0.0.0.0/0"],
        ),
    ],
    egress=[
        aws.ec2.SecurityGroupEgressArgs(
            protocol="-1",
            from_port=0,
            to_port=0,
            cidr_blocks=["0.0.0.0/0"],
        ),
    ],
)

# Create a security group for the ECS service
ecs_security_group = aws.ec2.SecurityGroup(
    f"{initials}-ecs-sg",
    vpc_id=vpc.id,
    description="Security group for ECS service",
    ingress=[
        aws.ec2.SecurityGroupIngressArgs(
            protocol="tcp",
            from_port=8000,
            to_port=8000,
            security_groups=[lb_security_group.id],
        ),
        aws.ec2.SecurityGroupIngressArgs(
            protocol="tcp",
            from_port=8100,
            to_port=8100,
            security_groups=[lb_security_group.id],
        ),
    ],
    egress=[
        aws.ec2.SecurityGroupEgressArgs(
            protocol="-1",
            from_port=0,
            to_port=0,
            cidr_blocks=["0.0.0.0/0"],
        ),
    ],
)

# Create a load balancer in the public subnets
load_balancer = aws.lb.LoadBalancer(
    f"{initials}-lb",
    internal=False,
    load_balancer_type="application",
    security_groups=[lb_security_group.id],
    subnets=[public_subnet1.id, public_subnet2.id],
)

# Create load balancer target group
target_group = aws.lb.TargetGroup(
    f"{initials}-tg",
    port=8000,
    protocol="HTTP",
    target_type="ip",
    vpc_id=vpc.id,
    health_check=aws.lb.TargetGroupHealthCheckArgs(
        path="/status",
        port="8100",
        protocol="HTTP",
        interval=30,
        timeout=5,
        healthy_threshold=2,
        unhealthy_threshold=2,
    ),
)

# Create a log group for ECS task logs
log_group = aws.cloudwatch.LogGroup(f"{initials}-log-group", retention_in_days=7)

# Create load balancer listener
listener = aws.lb.Listener(
    f"{initials}-listener",
    load_balancer_arn=load_balancer.arn,
    port=80,
    default_actions=[
        aws.lb.ListenerDefaultActionArgs(
            type="forward",
            target_group_arn=target_group.arn,
        )
    ],
)

# Create secrets for the certificate and key
crt_secret = aws.secretsmanager.Secret(
    f"{initials}-crt-secret",
    name=f"{initials}-crt",
    description="Certificate",
)

crt_secret_version = aws.secretsmanager.SecretVersion(
    f"{initials}-crt-secret-version",
    secret_id=crt_secret.id,
    secret_string=crt_content,
)

key_secret = aws.secretsmanager.Secret(
    f"{initials}-key-secret",
    name=f"{initials}-key",
    description="Key",
)

key_secret_version = aws.secretsmanager.SecretVersion(
    f"{initials}-key-secret-version",
    secret_id=key_secret.id,
    secret_string=key_content,
)

# Create an ECS cluster
cluster = aws.ecs.Cluster(f"{initials}-cluster")

# Create an IAM role for the ECS task
task_exec_role = aws.iam.Role(
    f"{initials}-task-exec-role",
    assume_role_policy=json.dumps(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {"Service": "ecs-tasks.amazonaws.com"},
                    "Effect": "Allow",
                    "Sid": "",
                }
            ],
        }
    ),
)

# Attach policies to the ECS task execution role
task_exec_role_policy = aws.iam.RolePolicyAttachment(
    f"{initials}-task-exec-role-policy",
    role=task_exec_role.name,
    policy_arn="arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
)

# Define the IAM policy for Secrets Manager access
secrets_manager_policy = aws.iam.Policy(
    f"{initials}-secrets-manager-policy",
    policy=pulumi.Output.all(crt_secret.arn, key_secret.arn).apply(
        lambda arns: json.dumps(
            {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": ["secretsmanager:GetSecretValue"],
                        "Resource": arns,
                    }
                ],
            }
        )
    ),
)

# Attach the Secrets Manager policy to the task execution role
secrets_manager_policy_attachment = aws.iam.RolePolicyAttachment(
    f"{initials}-secrets-manager-policy-attachment",
    role=task_exec_role.name,
    policy_arn=secrets_manager_policy.arn,
)

log_configurations = log_group.name.apply(
    lambda log_group_name: {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": log_group_name,
            "awslogs-region": aws_region,
            "awslogs-stream-prefix": "ecs",
        },
    }
)

container_definitions = pulumi.Output.all(
    log_configurations, crt_secret.arn, key_secret.arn
).apply(
    lambda values: json.dumps(
        [
            {
                "name": "kong-gateway",
                "image": "kong/kong-gateway:3.7.0.0",
                "portMappings": [
                    {"containerPort": 8000},
                    {"containerPort": 8100},
                    {"containerPort": 8443},
                ],
                "environment": [
                    {"name": "KONG_ROLE", "value": "data_plane"},
                    {"name": "KONG_DATABASE", "value": "off"},
                    {"name": "KONG_VITALS", "value": "off"},
                    {"name": "KONG_CLUSTER_MTLS", "value": "pki"},
                    {
                        "name": "KONG_CLUSTER_CONTROL_PLANE",
                        "value": kong_cluster_control_plane,
                    },
                    {
                        "name": "KONG_CLUSTER_SERVER_NAME",
                        "value": kong_cluster_server_name,
                    },
                    {
                        "name": "KONG_CLUSTER_TELEMETRY_ENDPOINT",
                        "value": kong_cluster_telemetry_endpoint,
                    },
                    {
                        "name": "KONG_CLUSTER_TELEMETRY_SERVER_NAME",
                        "value": kong_cluster_telemetry_server_name,
                    },
                    {"name": "KONG_STATUS_LISTEN", "value": "0.0.0.0:8100"},
                ],
                "secrets": [
                    {"name": "KONG_CLUSTER_CERT", "valueFrom": values[1]},
                    {"name": "KONG_CLUSTER_CERT_KEY", "valueFrom": values[2]},
                ],
                "logConfiguration": values[0],
            }
        ]
    )
)

# Define the task definition
task_definition = aws.ecs.TaskDefinition(
    f"{initials}-task",
    family=f"{initials}-task",
    cpu="256",
    memory="512",
    network_mode="awsvpc",
    requires_compatibilities=["FARGATE"],
    execution_role_arn=task_exec_role.arn,
    container_definitions=container_definitions,
)

# Create the ECS service
service = aws.ecs.Service(
    f"{initials}-service",
    cluster=cluster.arn,
    task_definition=task_definition.arn,
    desired_count=1,
    launch_type="FARGATE",
    network_configuration=aws.ecs.ServiceNetworkConfigurationArgs(
        subnets=[private_subnet.id],
        assign_public_ip=False,
        security_groups=[ecs_security_group.id],  # Specify appropriate security groups
    ),
    load_balancers=[
        aws.ecs.ServiceLoadBalancerArgs(
            target_group_arn=target_group.arn,
            container_name="kong-gateway",
            container_port=8000,
        )
    ],
)

# Output the created resources
pulumi.export("vpc_id", vpc.id.apply(str))
pulumi.export("public_subnet1_id", public_subnet1.id.apply(str))
pulumi.export("public_subnet2_id", public_subnet2.id.apply(str))
pulumi.export("private_subnet_id", private_subnet.id.apply(str))
pulumi.export("load_balancer_arn", load_balancer.arn.apply(str))
pulumi.export("load_balancer_dns", load_balancer.dns_name.apply(str))
pulumi.export("target_group_arn", target_group.arn.apply(str))
pulumi.export("listener_arn", listener.arn.apply(str))
pulumi.export("crt_secret_arn", crt_secret.arn.apply(str))
pulumi.export("key_secret_arn", key_secret.arn.apply(str))
pulumi.export("ecs_cluster_name", cluster.name.apply(str))
pulumi.export("ecs_service_name", service.name.apply(str))
pulumi.export("log_group_name", log_group.name.apply(str))
pulumi.export("nat_gateway_id", nat_gateway.id.apply(str))
pulumi.export("nat_eip_id", eip.id.apply(str))
