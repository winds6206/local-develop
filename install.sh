#!/bin/bash

storage="~/Documents/local_develop/k3d-storage"

mkdir -p ${storage}

cp -a ./registries.yaml $HOME/.k3d/

docker network create local-develop-network

k3d cluster create mycluster \
-p "1280:80@loadbalancer" \
-p "12443:443@loadbalancer" \
--volume ${storage}:/tmp/k3d-storage \
--volume $HOME/.k3d/registries.yaml:/etc/rancher/k3s/registries.yaml \
--agents 2

docker network connect local-develop-network k3d-mycluster-serverlb

docker-compose up -d

echo "\033[91m Notice!! Add below hosts into your /etc/hosts\n \033[0m"
echo "# local_develop"
echo "127.0.0.1 drone.tonyjhang.tk"
echo "127.0.0.1 gitea.tonyjhang.tk"
echo "127.0.0.1 registry.tonyjhang.tk"
echo "127.0.0.1 registry-frontend.tonyjhang.tk"
