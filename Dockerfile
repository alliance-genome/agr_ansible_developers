FROM 100225593120.dkr.ecr.us-east-1.amazonaws.com/agr_base_linux_env:latest

WORKDIR /usr/src/ansible

RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "    ServerAliveInterval 120" >> /etc/ssh/ssh_config
RUN mkdir /root/.ssh
RUN mkdir /root/.docker

RUN pip install wheel
RUN apt-get install python-setuptools
RUN pip install boto3

ADD . .

