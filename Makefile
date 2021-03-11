REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
CONTAINER := agr_ansible_run
TAG := latest

# Change this value to match the folder name you created in environments.
ENV=main

build: pull
	docker build -t ${REG}/${CONTAINER}:${TAG} .

pull:
	docker pull ${REG}/agr_base_linux_env:${TAG}

bash:
	docker run -it ${REG}/${CONTAINER}:${TAG} bash

launch: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_aws.yml --vault-password-file=.password

startdb: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_neo.yml --vault-password-file=.password

stopdb: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts stop_neo.yml --vault-password-file=.password

restartdb: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts restart_neo.yml --vault-password-file=.password

run_loader: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_loader.yml --vault-password-file=.password

run_indexer: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_indexer.yml --vault-password-file=.password

run_cacher: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_cacher.yml --vault-password-file=.password

run_api: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_api.yml --vault-password-file=.password

run_ui: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_ui.yml --vault-password-file=.password

run_nginx: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_nginx.yml --vault-password-file=.password

terminate: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts playbook_terminate_instance.yml --vault-password-file=.password

registry-docker-login:
ifneq ($(shell echo ${REG} | egrep "ecr\..+\.amazonaws\.com"),)
	@$(eval DOCKER_LOGIN_CMD=aws)
ifneq (${AWS_PROFILE},)
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} --profile ${AWS_PROFILE})
endif
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} ecr get-login-password | docker login -u AWS --password-stdin https://${REG})
	${DOCKER_LOGIN_CMD}
endif

# aws ecr get-login-password | docker login -u AWS --password-stdin https://100225593120.dkr.ecr.us-east-1.amazonaws.com