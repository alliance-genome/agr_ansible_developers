#!/bin/bash
# Fetch Ansible vault password from AWS Secrets Manager
# This script should only be used when .password file doesn't exist or needs refreshing

set -e  # Exit on any error

# Build AWS CLI command
GET_SECRET_CMD="docker run --rm -v ${HOME}/.aws:/root/.aws amazon/aws-cli"

# Pass on AWS profile env variable if set
if [ ! -z "${AWS_PROFILE}" ]; then
    GET_SECRET_CMD="${GET_SECRET_CMD} --profile ${AWS_PROFILE}"
fi

# Fetch secret from AWS Secrets Manager
# Note: Removed -it flag as it causes issues with output redirection
echo "Fetching Ansible vault password from AWS Secrets Manager..." >&2

SECRET_OUTPUT=$(${GET_SECRET_CMD} secretsmanager get-secret-value \
    --region us-east-1 \
    --secret-id AnsibleDevelopers \
    --query SecretString \
    --output text 2>&1)

# Check if AWS CLI command succeeded
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to fetch secret from AWS Secrets Manager" >&2
    echo "AWS CLI output: ${SECRET_OUTPUT}" >&2
    echo "" >&2
    echo "Troubleshooting steps:" >&2
    echo "1. Ensure you have valid AWS credentials configured (~/.aws/credentials or environment variables)" >&2
    echo "2. Verify your AWS profile has access to Secrets Manager" >&2
    echo "3. Check that you're using the correct AWS_PROFILE if needed" >&2
    echo "4. As a workaround, you can manually create .password file (ask team for the password)" >&2
    exit 1
fi

# Extract the actual password from the response
# The secret might be returned with or without quotes, so handle both cases
PASSWORD=$(echo "${SECRET_OUTPUT}" | grep -o '"[^"]\+"' | sed 's/"//g')

# If the grep didn't match (no quotes), assume the output is the plain password
if [ -z "${PASSWORD}" ]; then
    PASSWORD="${SECRET_OUTPUT}"
fi

# Validate we got something
if [ -z "${PASSWORD}" ]; then
    echo "ERROR: Retrieved secret but password extraction failed" >&2
    echo "Secret output: ${SECRET_OUTPUT}" >&2
    exit 1
fi

# Output the password (will be redirected to .password file by Makefile)
echo -n "${PASSWORD}"
echo "Successfully fetched password from AWS Secrets Manager" >&2
