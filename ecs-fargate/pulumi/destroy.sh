# Authenticate using saml2aws
saml2aws login

# Export AWS credentials
eval $(saml2aws script)

# Initialize Pulumi
pulumi destroy

