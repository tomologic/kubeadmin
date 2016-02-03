#!/bin/bash
. ~/.bashrc

PROJECT="$1"
ZONE="$2"
CLUSTER="$3"
KEYFILE="$4"

if [ -z "$KEYFILE" ];then
  echo "Usage: $(basename $0) PROJECT ZONE CLUSTER KEYFILE"
  echo
  echo "Arguments:"
  echo "  PROJECT  The project ID in which the cluster resides"
  echo "  ZONE     Availability zone to use"
  echo "  CLUSTER  The GCE container cluster to be managed"
  echo "  KEYFILE  Service account json key file to use"
  exit 1
fi

if [ ! -f "$KEYFILE" ];then
  echo "No such file: $KEYFILE"
  exit 2
fi

if [ -d secrets/.kube ];then
  echo "Already initialized, directory secrets/.kube exists"
  exit 0
fi

EMAIL=$(cat "$KEYFILE" | grep -E client_email | cut -d\" -f 4)

gcloud auth activate-service-account "$EMAIL" --key-file "$KEYFILE"
gcloud container clusters get-credentials "$CLUSTER" --zone="$ZONE" --project="$PROJECT"
gcloud config set project "$PROJECT"

echo -e "\nTesting use of the kubectl command"
kubectl version

if [ $? -ne 0 ];then
  echo "Error: failed to interact with cluster"
  exit 3
fi

mv .config .kube secrets/
ln -s secrets/.config
ln -s secrets/.kube

cat <<EOS

Success! kubectl and gcloud commands initialized

Usage:
docker run --rm -ti -v \$PWD/secrets/.config:/root/.config -v \$PWD/secrets/.kube:/root/.kube tomologic/kubeadmin <command> <args>'

Examples:
alias c="docker run --rm -ti -v \$PWD/secrets/.config:/root/.config -v \$PWD/secrets/.kube:/root/.kube tomologic/kubeadmin"
c kubectl get pods
c gcloud container clusters list
EOS

