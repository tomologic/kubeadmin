FROM debian:jessie
RUN apt-get update \
 && apt-get -y install python python-openssl curl \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Prepare installation of the k8s tools
ENV CLOUDSDK_PYTHON_SITEPACKAGES=1
WORKDIR /root

RUN curl https://sdk.cloud.google.com | bash
RUN bash -c ". google-cloud-sdk/path.bash.inc && gcloud config set disable_usage_reporting false && gcloud components install kubectl"

ENV PATH $PATH:/root/google-cloud-sdk/bin
COPY ./initialize.sh $HOME/google-cloud-sdk/bin/initialize

