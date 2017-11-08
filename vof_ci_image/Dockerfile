# Custom Dockerfile with packer & terraform
#
FROM circleci/python:2.7.13

USER root

RUN mkdir -p /workdir

ADD https://releases.hashicorp.com/packer/1.1.0/packer_1.1.0_linux_amd64.zip /workdir/
ADD https://releases.hashicorp.com/terraform/0.10.6/terraform_0.10.6_linux_amd64.zip /workdir/

RUN cd /workdir \
  && unzip packer_1.1.0_linux_amd64.zip \
  && chmod +x packer \
  && mv packer /usr/local/bin/ \
  && unzip terraform_0.10.6_linux_amd64.zip \
  && chmod +x terraform \
  && mv terraform /usr/local/bin/ \
  && rm -r /workdir

USER circleci
