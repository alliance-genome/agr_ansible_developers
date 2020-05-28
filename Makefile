build: pull
	docker build -t agrdocker/agr_ansible_run:latest .

pull:
	docker pull agrdocker/agr_base_linux_env:latest

bash:
	docker run -it agrdocker/agr_ansible_run:latest bash

launch:
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=olin -i hosts launch_aws.yml --vault-password-file=.password

restart_elk:
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e env=olin -i hosts restart_elk.yml --vault-password-file=.password

run_loader:
	docker run -it agrdocker/agr_ansible_run:latest ansible-playbook -e ALLIANCE_RELEASE=3.1.0 -e env=olin -e DEV_BRANCH=bug_fixes_3.1.0 -i hosts launch_loader.yml --vault-password-file=.password


