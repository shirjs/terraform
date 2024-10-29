#!/bin/bash

sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world

#add to avoid sudo 

sudo groupadd docker
sudo gpasswd -a ubuntu docker
newgrp docker
sleep 10

# get instance ip
export KUBECONFIG=/home/ubuntu/.kube/config
INSTANCE_IP=$(curl -s https://checkip.amazonaws.com)

# install k3s
curl -sfL https://get.k3s.io | sh -

# wait for k3s to be ready
sleep 30

# configure k3s
sudo mkdir -p /etc/rancher/k3s
sudo chown -R ubuntu:ubuntu /etc/rancher/k3s

# get k3s kubeconfig
mkdir -p /home/ubuntu/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
sudo chmod 600 /home/ubuntu/.kube/config

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl



SECONDS_PASSED=0
while ! kubectl get nodes >/dev/null 2>&1; do
    echo "Waiting for Kubernetes API server to be fully ready... seconds passted $SECONDS_PASSED"
    sleep 10
    SECONDS_PASSED=$((SECONDS_PASSED + 10))
    kubectl config current-context
done
sleep 30
# install nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.5/deploy/static/provider/cloud/deploy.yaml 

# wait for ingress controller to be ready
sleep 300

# configure coredns for wildcard DNS 
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
      errors
      health
      ready
      kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
      }
      hosts {
        *.apps.k3s.company.com $INSTANCE_IP
        fallthrough
      }
      prometheus :9153
      forward . /etc/resolv.conf
      cache 30
      loop
      reload
      loadbalance
  }
EOF

cat <<'DEPLOYEOF' > /home/ubuntu/deploy.sh
${deploy_script}
DEPLOYEOF

cat <<'TOOLSEOF' > /home/ubuntu/dev-tools.sh
${dev_tools_script}
TOOLSEOF

# verify setup
kubectl get nodes
kubectl get pods -n ingress-nginx
kubectl get pods -n kube-system

chmod +x /home/ubuntu/deploy.sh /home/ubuntu/dev-tools.sh
chown ubuntu:ubuntu /home/ubuntu/deploy.sh /home/ubuntu/dev-tools.sh

