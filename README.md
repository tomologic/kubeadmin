# Google Container Engine management container
This project provides a docker image with the google SDK to ease making
management operations on Google's kubernetes implementation.

The image contains both gcloud (for authentication and infra needs) as well as
kubectl of a version that matches the version of kubernetes that google has
deployed at the time the image is built.

Left up to the user is mounting credential information, such as a service
account key, into the container, to provide the container the authority to
manage the kubernetes cluster(s) and other cloud resources in Google Cloud.

## A) Preparation - stateless use
Does not require any initialization and is suitable for when one wants
ephemeral use, such as in a CI product.

There is just one requirement, that you have populated a gcloud credentials
file with the service account information you want to use, and mounted it into
the container at: `/root/.config/gcloud/credentials`

## B) Preparation - stateful use
The benefit of stateful configuration is that you can separate configuration
from use, into distinct lifecycle steps, suitable for running on one's private
laptop to save on needless typing. The downside is that your risk clobbering
the configuration if you frequently need to swap between configurations (such
as in a CI system).

Stateful use of the container requires an initial configuration of kubectl and
gcloud, so that the SDK knows where your cluster is and what credential to use.

The following assumptions have been made:
* A service account for use with Google Container Engine already exists.
* A private key for the service account has been saved in the project folder as
  `secrets/key.json`.

To initialize the use of `kubectl` for a kubernetes cluster, run the following:
````
docker run --rm -ti -v $PWD/secrets:/root/secrets tomologic/kubeadmin \
  initialize <project-id> <region> <cluster> secrets/key.json
````
* _project-id_ is the ID of the project that contains the kubernetes cluster
* _availability-zone_ is the zone where the cluster resides
* _cluster_ is the name of the container cluster
* _secrets/key.json_ is the path to the file in the container containing the
  service account private key.

## Usage
Example use of SDK with stateful context, after initialization:
````
alias c="docker run --rm -i -v $PWD/secrets/.config:/root/.config -v $PWD/secrets/.kube:/root/.kube tomologic/kubeadmin"
c kubectl get pods
c gcloud container clusters list
````

Example of stateless use:
````
docker run --rm -i \
-v $HOME/.config/gcloud/credentials:/root/.config/gcloud/credentials:ro \
-e CLOUDSDK_COMPUTE_ZONE=europe-west1-a \
-e CLOUDSDK_COMPUTE_REGION=europe-west1 \
tomologic/kubeadmin gcloud \
--project my-project \
--account jenkins@my-project.iam.gserviceaccount.com \
compute instances list
````
_Note that the account used needs to have been imported into the host's
credentials file first. Refer to Google's docs on the sibject for how to use
their tools._
