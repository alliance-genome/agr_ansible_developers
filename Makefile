REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
TAG := latest
include .makerc

registry-docker-login:
ifneq ($(shell echo ${REG} | egrep "ecr\..+\.amazonaws\.com"),)
	@$(eval DOCKER_LOGIN_CMD=aws)
ifneq (${AWS_PROFILE},)
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} --profile ${AWS_PROFILE})
endif
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} ecr get-login-password | docker login -u AWS --password-stdin https://${REG})
	${DOCKER_LOGIN_CMD}
endif

build: registry-docker-login pull-base
	docker build -t agrlocal/agr_ansible_run_unlocked:${TAG} --build-arg REG=${REG} --build-arg ALLIANCE_RELEASE=${TAG} .

pull-base: registry-docker-login
	docker pull ${REG}/agr_base_linux_env:${TAG}

bash:
	docker run -it agrlocal/agr_ansible_run_unlocked:${TAG} bash

launch: require-ENV
	docker run -it agrlocal/agr_ansible_run_unlocked:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_aws.yml --vault-password-file=.password

startdb: require-ENV
	docker run -it agrlocal/agr_ansible_run_unlocked:${TAG} ansible-playbook -e env=${ENV} -i hosts start_neo.yml --vault-password-file=.password

stopdb: require-ENV
	docker run -it agrlocal/agr_ansible_run_unlocked:${TAG} ansible-playbook -e env=${ENV} -i hosts stop_neo.yml --vault-password-file=.password

restartdb: require-ENV
	docker run -it agrlocal/agr_ansible_run_unlocked:${TAG} ansible-playbook -e env=${ENV} -i hosts restart_neo.yml --vault-password-file=.password

restart_elk: require-ENV
	docker run -it agrlocal/agr_ansible_run_unlocked:${TAG} ansible-playbook -e env=${ENV} -i hosts restart_elk.yml --vault-password-file=.password

run_loader: require-ENV require-ALLIANCE_RELEASE require-DEV_BRANCH
	docker run -it agrlocal/agr_ansible_run_unlocked:${TAG} ansible-playbook -e ALLIANCE_RELEASE=${ALLIANCE_RELEASE} -e env=${ENV} -e DEV_BRANCH=${DEV_BRANCH} -i hosts launch_loader.yml --vault-password-file=.password


require-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi
