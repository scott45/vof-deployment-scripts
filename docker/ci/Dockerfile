# Custom Dockerfile with packer & terraform
#

FROM circleci/ruby:2.4.1-node-browsers

USER root

RUN mkdir -p /workdir
# install and configure gcloudSDK
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz
RUN mkdir -p /usr/local/gcloud
RUN tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz
RUN /usr/local/gcloud/google-cloud-sdk/install.sh
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# install beta components
RUN gcloud components install beta --quiet

# install packer
ADD https://releases.hashicorp.com/packer/1.1.0/packer_1.1.0_linux_amd64.zip /workdir/

# install terraform
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