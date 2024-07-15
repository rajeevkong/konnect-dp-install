#!/bin/bash

# Set Pulumi configuration parameters
pulumi config set initials RR-P30
pulumi config set crtFilePath /path/to/crt/file 
pulumi config set keyFilePath /path/to/key/file
pulumi config set awsRegion us-east-1

pulumi config set KONG_CLUSTER_CONTROL_PLANE AAA.us.cp0.konghq.com:443
pulumi config set KONG_CLUSTER_SERVER_NAME AAA.us.cp0.konghq.com
pulumi config set KONG_CLUSTER_TELEMETRY_ENDPOINT AAA.us.tp0.konghq.com:443
pulumi config set KONG_CLUSTER_TELEMETRY_SERVER_NAME AAA.us.tp0.konghq.com

# Authenticate using saml2aws
saml2aws login

# Export AWS credentials
eval $(saml2aws script)

# Initialize Pulumi
pulumi login

# Preview the changes
pulumi preview

# Run Pulumi up to deploy the stack
pulumi up

