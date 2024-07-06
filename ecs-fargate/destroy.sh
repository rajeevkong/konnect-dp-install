#!/bin/bash

# Authenticate using saml2aws
saml2aws login

# Export AWS credentials
eval $(saml2aws script)

# Run Terraform
terraform destroy

