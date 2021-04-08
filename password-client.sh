GET_SECRET_CMD="docker run --rm -it -v ${HOME}/.aws:/root/.aws amazon/aws-cli"

#Pass on AWS profile env variable
if [ ! -z ${AWS_PROFILE} ]; then
	GET_SECRET_CMD="${GET_SECRET_CMD} --profile ${AWS_PROFILE}"
fi

${GET_SECRET_CMD} secretsmanager get-secret-value --region us-east-2 --secret-id AnsibleDevelopers --query SecretString --output text
