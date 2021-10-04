#!/bin/bash

k3d_storage="$HOME/Documents/local_develop/k3d-storage" # k3d與本機掛載的空間

echo "\033[32m \n建立 k3d本機掛載空間 ${k3d_storage} \033[0m"
mkdir -p ${k3d_storage}

echo "\033[32m \n複製 registries.yaml 到 $HOME/.k3d/ \033[0m"
cp -a ./registries.yaml $HOME/.k3d/

echo "\033[32m \n建立 local-develop-network \033[0m"
docker network create local-develop-network

echo "\033[32m \n建立 k3d 叢集 \033[0m"
k3d cluster create mycluster \
-p "1280:80@loadbalancer" \
-p "12443:443@loadbalancer" \
--volume ${k3d_storage}:/tmp/k3d-storage \
--volume $HOME/.k3d/registries.yaml:/etc/rancher/k3s/registries.yaml \
--agents 2

# -p "1280:80@loadbalancer" -p "12443:443@loadbalancer" 使用 Ingress 需要指定 port-mapping
# --volume ${k3d_storage}:/tmp/k3d-storage 指定本機掛載位置
# --volume $HOME/.k3d/registries.yaml:/etc/rancher/k3s/registries.yaml 指定自建 docker-registry

echo "\033[32m \n將 local-develop-network 網路綁定到 k3d-mycluster-serverlb \033[0m"
docker network connect local-develop-network k3d-mycluster-serverlb # 將 local-develop-network 網路綁定到 k3d-mycluster-serverlb 的容器上，為了讓 Drone 可以進行發佈

echo "\033[32m \n啟動第一階段的 docker-compose \033[0m"
docker-compose -f docker-compose-pre.yaml up -d
# docker-compose -f docker-compose-pre.yaml down → 指定 file 結束的方式

echo "\033[91m \nNotice!! Add below hosts into your /etc/hosts \033[0m"
echo "# local_develop"
echo "127.0.0.1 drone.tonyjhang.tk"
echo "127.0.0.1 gitea.tonyjhang.tk"
echo "127.0.0.1 registry.tonyjhang.tk"
echo "127.0.0.1 registry-frontend.tonyjhang.tk"
