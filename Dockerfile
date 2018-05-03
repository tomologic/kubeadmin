FROM alpine:3.7
RUN apk add --no-cache bash curl make python

# Prepare installation of the k8s tools
ENV GOOGLE_CLOUD_SDK_VERSION=200.0.0 \
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

# Helm
ENV HELM_VERSION v2.9.0

RUN curl -so- https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xzvf - \
  && mv /root/linux-amd64/helm /bin/helm \
  && rm -rvf /root/linux-amd64
RUN helm init --client-only
# Besides stable charts add incubator charts too
RUN helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/

COPY ./initialize.sh /root/google-cloud-sdk/bin/initialize

CMD ["/bin/bash"]
