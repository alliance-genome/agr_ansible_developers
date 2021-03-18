REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
TAG := latest
CONTAINER := agr_ansible_run

# Change this value to match the folder name you created in environments.
ENV=chris

registry-docker-login:
ifneq ($(shell echo ${REG} | egrep "ecr\..+\.amazonaws\.com"),)
	@$(eval DOCKER_LOGIN_CMD=aws)
ifneq (${AWS_PROFILE},)
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} --profile ${AWS_PROFILE})
endif
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} ecr get-login-password | docker login -u AWS --password-stdin https://${REG})
	${DOCKER_LOGIN_CMD}
endif

build:
	docker build -t agrlocal/agr_ansible_run_unlocked:${TAG} --build-arg REG=${REG} --build-arg ALLIANCE_RELEASE=${TAG} .

pull:
	docker pull ${REG}/agr_base_linux_env:${TAG}

bash:
	docker run -it agrlocal/agr_ansible_run_unlocked:${TAG} bash

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

run_loader_tests: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_loader_tests.yml --vault-password-file=.password

start_infinispan: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_infinispan.yml --vault-password-file=.password

run_indexer: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_indexer.yml --vault-password-file=.password

run_cacher: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_cacher.yml --vault-password-file=.password

start_api: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_api.yml --vault-password-file=.password

start_ui: build
	docker run -it ${REG}/${CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_ui.yml --vault-password-file=.password

start_nginx: build
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

# awsv2 ecr get-login-password | docker login -u AWS --password-stdin https://100225593120.dkr.ecr.us-east-1.amazonaws.com
