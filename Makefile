REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
LOCAL_RUN_CONTAINER := agrlocal/agr_ansible_run_unlocked
TAG := latest

# Change this value to match the folder name you created in environments.
ENV=chris

registry-docker-login:
ifneq ($(shell echo ${REG} | egrep "ecr\..+\.amazonaws\.com"),)
	@$(eval DOCKER_LOGIN_CMD=docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli)
ifneq (${AWS_PROFILE},)
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} --profile ${AWS_PROFILE})
endif
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} ecr get-login-password | docker login -u AWS --password-stdin https://${REG})
	${DOCKER_LOGIN_CMD}
endif

build: pull registry-docker-login
	docker build -t ${LOCAL_RUN_CONTAINER}:${TAG} .

pull: registry-docker-login
	docker pull ${REG}/agr_base_linux_env:${TAG}

bash:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} bash

launch: build
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_aws.yml --vault-password-file=.password

startdb:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_neo.yml --vault-password-file=.password

stopdb:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts stop_neo.yml --vault-password-file=.password

restartdb:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts restart_neo.yml --vault-password-file=.password

run_loader:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_loader.yml --vault-password-file=.password

run_loader_tests:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_loader_tests.yml --vault-password-file=.password

start_infinispan:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_infinispan.yml --vault-password-file=.password

run_indexer:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_indexer.yml --vault-password-file=.password

run_cacher:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_cacher.yml --vault-password-file=.password

start_api:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_api.yml --vault-password-file=.password

start_ui:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_ui.yml --vault-password-file=.password

start_nginx:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_nginx.yml --vault-password-file=.password

terminate:
	docker run -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts playbook_terminate_instance.yml --vault-password-file=.password
