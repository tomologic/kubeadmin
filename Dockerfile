FROM debian:jessie
RUN apt-get update \
 && apt-get -y install python python-openssl curl \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the k8s tools and run this container as a non-root user
RUN useradd --create-home kube
USER kube
WORKDIR /home/kube
ENV CLOUDSDK_PYTHON_SITEPACKAGES=1

RUN curl https://sdk.cloud.google.com | bash
RUN bash -c ". /home/kube/google-cloud-sdk/path.bash.inc && gcloud config set disable_usage_reporting false && gcloud components install kubectl"

