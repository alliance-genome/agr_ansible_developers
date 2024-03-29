ARG ALLIANCE_RELEASE=stage
ARG REG=100225593120.dkr.ecr.us-east-1.amazonaws.com

FROM ${REG}/agr_base_linux_env:${ALLIANCE_RELEASE}

RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "    ServerAliveInterval 120" >> /etc/ssh/ssh_config
RUN mkdir /root/.ssh
RUN mkdir /root/.docker

WORKDIR /usr/src/ansible

