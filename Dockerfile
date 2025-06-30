# Avoid 3.14 because of https://gitlab.alpinelinux.org/alpine/aports/-/issues/12396
FROM python:3.10-alpine3.13
# libc6-compat is installed to support `process.dlopen`, used by gcloud
RUN apk add --no-cache bash curl make jq libc6-compat

# Prepare installation of the k8s tools
# GKE auth: https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
ENV PATH=/opt/google-cloud-sdk/bin:$PATH \
    GOOGLE_CLOUD_SDK_VERSION=528.0.0 \
    CLOUDSDK_CORE_DISABLE_PROMPTS=1 \
    CLOUDSDK_PYTHON_SITEPACKAGES=1 \
    GCLOUD_SDK_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz \
    USE_GKE_GCLOUD_AUTH_PLUGIN=True

RUN curl -sL $GCLOUD_SDK_URL | tar -C /opt -xzf - \
    && rm -rf /opt/google-cloud-sdk/platform/bundledpythonunix \
    && gcloud config set core/disable_usage_reporting true \
    && gcloud config set component_manager/disable_update_check true \
    && gcloud components install -q beta gsutil gke-gcloud-auth-plugin \
    && rm -rf $(find /opt/google-cloud-sdk/ -regex ".*/__pycache__") \
    && rm -rf /opt/google-cloud-sdk/.install/.backup \
    && rm -rf /opt/google-cloud-sdk/bin/anthoscli \
    && gsutil version \
    && gke-gcloud-auth-plugin --version

# Install newer kubectl than the one bundled with gcloud SDK
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && kubectl version --client=true

# Helm
# https://github.com/helm/helm/releases
ENV HELM_VERSION v3.18.3

RUN mkdir /opt/helm \
    && curl -sL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
       | tar -C /opt/helm -xzvf - \
    && mv /opt/helm/linux-amd64/helm /bin/helm \
    && rm -rvf /opt/helm \
    && helm version

COPY ./initialize.sh /opt/google-cloud-sdk/bin/initialize

CMD ["/bin/bash"]
