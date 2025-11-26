REG := 100225593120.dkr.ecr.us-east-1.amazonaws.com
LOCAL_RUN_CONTAINER := agrlocal/agr_ansible_run_unlocked
TAG := stage
AWS_DEFAULT_REGION := us-east-1

# Change this value to match the folder name you created in environments.
ENV=chris

registry-docker-login:
ifneq ($(shell echo ${REG} | egrep "ecr\..+\.amazonaws\.com"),)
	@$(eval DOCKER_LOGIN_CMD=docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli)
ifneq (${AWS_PROFILE},)
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} --profile ${AWS_PROFILE})
endif
	@$(eval DOCKER_LOGIN_CMD=${DOCKER_LOGIN_CMD} ecr get-login-password --region=${AWS_DEFAULT_REGION} | docker login -u AWS --password-stdin https://${REG})
	${DOCKER_LOGIN_CMD}
endif

password:
	install -m 600 /dev/null .password
	./password-client.sh > .password

build: pull registry-docker-login password
	docker build -t ${LOCAL_RUN_CONTAINER}:${TAG} .

pull: registry-docker-login
	docker pull ${REG}/agr_base_linux_env:${TAG}

bash:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} bash

launch: build
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_aws.yml --vault-password-file=.password

startdb:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_neo.yml --vault-password-file=.password

startcurationdb:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_curation.yml --vault-password-file=.password

stopdb:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts stop_neo.yml --vault-password-file=.password

stopcurationdb:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts stop_curation.yml --vault-password-file=.password

restartdb:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts restart_neo.yml --vault-password-file=.password

restartcurationdb:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts restart_curation.yml --vault-password-file=.password

restartelk:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts restart_elk.yml --vault-password-file=.password

run_loader:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_loader.yml --vault-password-file=.password

run_loader_tests:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_loader_tests.yml --vault-password-file=.password

run_file_generator:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_file_generator.yml --vault-password-file=.password

run_file_generator_no_upload:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_file_generator_no_upload.yml --vault-password-file=.password

start_infinispan:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_infinispan.yml --vault-password-file=.password

run_indexer:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_indexer.yml --vault-password-file=.password

run_mod_variant_indexer:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_mod_variant_indexer.yml --vault-password-file=.password

run_human_variant_indexer:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_human_variant_indexer.yml --vault-password-file=.password

run_cacher:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_cacher.yml --vault-password-file=.password

start_api:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_api.yml --vault-password-file=.password

start_ui:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_ui.yml --vault-password-file=.password

start_es_cluster:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_es_cluster.yml --vault-password-file=.password

start_nginx:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts launch_nginx.yml --vault-password-file=.password

feature-stack:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts playbook_launch_feature_stack.yml --vault-password-file=.password

terminate:
	docker run --rm -it -v `pwd`:/usr/src/ansible/ ${LOCAL_RUN_CONTAINER}:${TAG} ansible-playbook -e env=${ENV} -i hosts playbook_terminate_instance.yml --vault-password-file=.password
