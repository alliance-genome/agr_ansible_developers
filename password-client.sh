secret1=$(docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli secretsmanager get-secret-value --region us-east-2 --secret-id AnsibleDevelopers --version-stage AWSCURRENT --query SecretString --output text | grep -o '"[^"]\+"' | sed 's/"//g')
export ENV1=${secret1}
echo ${ENV1}