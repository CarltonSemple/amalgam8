#!/bin/bash

export K8S_VERSION="v1.3.10"
export ARCH=amd64

docker run \
    --volume=/:/rootfs:ro \
    --volume=/sys:/sys:ro \
    --volume=/var/lib/docker/:/var/lib/docker:rw \
    --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
    --volume=/var/run:/var/run:rw \
    --net=host \
    --pid=host \
    --privileged=true \
    --name=kubelet \
    -d \
    gcr.io/google_containers/hyperkube-${ARCH}:${K8S_VERSION} \
    /hyperkube kubelet \
        --containerized \
        --hostname-override=127.0.0.1 \
        --address=0.0.0.0 \
        --api-servers=http://0.0.0.0:8080 \
        --config=/etc/kubernetes/manifests \
        --allow-privileged=true --v=2

curl -L http://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/${ARCH}/kubectl > /tmp/kubectl
sudo mv /tmp/kubectl /usr/local/bin
sudo chmod +x /usr/local/bin/kubectl

