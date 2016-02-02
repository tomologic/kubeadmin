# Google Container Engine management container
This project provides a docker image with the google SDK to ease making management operations with Google's kubernetes implementation.

The image contains both gcloud (for authentication needs) as well as kubectl of a version that matches the version of kubernetes that google has deployed at the time the image is built.

Left up to the user is mounting credential information, such as a service account key, into the container, to provide the container the authority to manage the kubernetes cluster(s) in Google Cloud.
