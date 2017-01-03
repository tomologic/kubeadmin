FROM debian:jessie
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && apt-get -y install python python-openssl curl make \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Prepare installation of the k8s tools
ENV GOOGLE_CLOUD_SDK_VERSION=138.0.0 \
    CLOUDSDK_PYTHON_SITEPACKAGES=1 \
    DOWNLOAD_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz \
    PATH=$PATH:/root/google-cloud-sdk/bin

WORKDIR /root

RUN curl -so- $DOWNLOAD_URL | tar -xzf -
RUN google-cloud-sdk/install.sh \
    --usage-reporting=false \
    --path-update=true \
    --bash-completion=true \
    --rc-path=/root/.bashrc \
    --additional-components kubectl alpha beta \

# Ensure the sdk version used is the one specified
 && (gcloud version | grep -q "Google Cloud SDK $GOOGLE_CLOUD_SDK_VERSION" \
     || gcloud components update --version $GOOGLE_CLOUD_SDK_VERSION)

RUN gcloud config set --installation component_manager/disable_update_check true

COPY ./initialize.sh /root/google-cloud-sdk/bin/initialize

