build: pull
	docker build -t agrdocker/agr_ansible_run:latest .

pull:
	docker pull agrdocker/agr_base_linux_env:latest

bash:
	docker run -it agrdocker/agr_ansible_run:latest bash

launch: require-ENV
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=${ENV} -i hosts launch_aws.yml --vault-password-file=.password

startdb: require-ENV
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=${ENV} -i hosts start_neo.yml --vault-password-file=.password

stopdb: require-ENV
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=${ENV} -i hosts stop_neo.yml --vault-password-file=.password

restartdb: require-ENV
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=${ENV} -i hosts restart_neo.yml --vault-password-file=.password

restart_elk: require-ENV
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=${ENV} -i hosts restart_elk.yml --vault-password-file=.password

run_loader: require-ENV require-ALLIANCE_RELEASE require-DEV_BRANCH
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e ALLIANCE_RELEASE=${ALLIANCE_RELEASE} -e env=${ENV} -e DEV_BRANCH=${DEV_BRANCH} -i hosts launch_loader.yml --vault-password-file=.password


require-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi
