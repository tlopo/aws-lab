# Dockerfile
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive\
    PACKER_VERSION=1.1.3\
    TERRAFORM_VERSION=0.11.1\
    CHEFDK_VERSION=2.4.17 

RUN apt-get update && apt-get install -y \ 
    build-essential \ 
    curl \ 
    devscripts \ 
    equivs \ 
    git-buildpackage \ 
    git \ 
    lsb-release \ 
    make \ 
    openssh-client \ 
    pristine-tar \ 
    fakeroot \
    dpkg-sig \ 
    rake \ 
    rsync \ 
    ruby \ 
    openjdk-8-jdk \ 
    rubygems \ 
    docker.io \ 
    python-pip \ 
    wget; \
    touch /release

RUN cd /tmp && curl  -o packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip &&\
    unzip /tmp/packer.zip &&\
    mv packer /usr/bin &&\
    rm /tmp/packer.zip

RUN cd /tmp && curl -sfo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip &&\
    unzip terraform.zip &&\
    mv terraform /usr/bin  &&\
    rm terraform.zip

RUN cd /tmp && curl -o chefdk.deb https://packages.chef.io/files/stable/chefdk/${CHEFDK_VERSION}/ubuntu/16.04/chefdk_${CHEFDK_VERSION}-1_amd64.deb &&\
    dpkg -i chefdk.deb &&  rm chefdk.deb

RUN apt-get install -y python-pip && pip install awscli
