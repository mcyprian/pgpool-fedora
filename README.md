# Pgpool-II container images

Fedora based Pgpool-II container images for Kubernetes and Openshift.

For more information about configuration and usage of Pgpool-II, see the official [Pgpool-II
Documentation](https://www.pgpool.net/docs/latest/en/html/index.html).

## Getting started

Update Pgpool-II configuration file in root/etc/pgpool-II-template/pgpool.conf according to your
needs.

Building an image:

    $ docker build --no-cache -t  <image-name>:<image-tag> -f Dockerfile .

Optionally replace the image in the k8s/deployment.yaml manifest with your build.

Deploy Pgpool-II into the Kubernetes cluster:

    $ kubectl apply -f k8s/service.yaml
    $ kubectl apply -f k8s/deployment.yaml
