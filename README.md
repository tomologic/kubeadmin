# Google Container Engine management container
This project provides a docker image with the google SDK to ease making management operations with Google's kubernetes implementation.

The image contains both gcloud (for authentication needs) as well as kubectl of a version that matches the version of kubernetes that google has deployed at the time the image is built.

Left up to the user is mounting credential information, such as a service account key, into the container, to provide the container the authority to manage the kubernetes cluster(s) in Google Cloud.

## Initialize for use
This example shows how to perform a one-time initial configuration of kubectl, so that it knows where your cluster is and what credential to use.

The following assumptions have been made for this example:
* A service account for use with Google Container Engine already exists.
* A private key for the service account has been saved in the project folder as `secrets/key.json`.

To initialize the use of `kubectl` for a kubernetes cluster, run the following:
````
docker run --rm -ti -v $PWD/secrets:/root/secrets tomologic/kubeadmin \
  initialize <project-id> <availability-zone> <cluster> secrets/key.json
````
* _project-id_ is the ID of the project that contains the kubernetes cluster
* _availability-zone_ is the zone where the cluster resides
* _cluster_ is the name of the container cluster
* _secrets/key.json_ is the path to the file in the container containing the service account private key.

## Usage
Example use after initialization:
````
alias c="docker run --rm -ti -v $PWD/secrets/.config:/root/.config -v $PWD/secrets/.kube:/root/.kube tomologic/kubeadmin"
c kubectl get pods
c gcloud container clusters list
````

