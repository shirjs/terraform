#!/bin/bash

# deploy.sh
# Usage: ./deploy.sh <developer-id> <image-name> <port>

if [ "$#" -ne 3 ]; then
    echo "Usage: ./deploy.sh <developer-id> <image-name> <port>"
    echo "Example: ./deploy.sh john myregistry.com/myapp:latest 8080"
    exit 1
fi

DEVELOPER_ID=$1
IMAGE_NAME=$2
PORT=$3

# Create a deployment name from image name (remove registry and tag, replace / with -)
DEPLOY_NAME=$(echo $IMAGE_NAME | sed 's/.*\///' | sed 's/:.*$//' | tr '._' '--')

# Create a unique name for this deployment using timestamp
TIMESTAMP=$(date +%s)
UNIQUE_NAME="${DEPLOY_NAME}-${TIMESTAMP}"

# Create namespace if it doesn't exist
kubectl create namespace ${DEVELOPER_ID} --dry-run=client -o yaml | kubectl apply -f -

# Create resource quota for the namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ${DEVELOPER_ID}-quota
  namespace: ${DEVELOPER_ID}
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
    services: "5"
EOF

# Create deployment and service YAML
cat <<EOF | kubectl apply -n ${DEVELOPER_ID} -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${UNIQUE_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${UNIQUE_NAME}
  template:
    metadata:
      labels:
        app: ${UNIQUE_NAME}
        developer: ${DEVELOPER_ID}
    spec:
      containers:
      - name: ${DEPLOY_NAME}
        image: ${IMAGE_NAME}
        ports:
        - containerPort: ${PORT}
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: ${UNIQUE_NAME}
spec:
  type: NodePort
  ports:
  - port: ${PORT}
    targetPort: ${PORT}
  selector:
    app: ${UNIQUE_NAME}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${UNIQUE_NAME}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: ${UNIQUE_NAME}.${DEVELOPER_ID}.apps.k3s.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ${UNIQUE_NAME}
            port:
              number: ${PORT}
EOF

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available deployment/${UNIQUE_NAME} -n ${DEVELOPER_ID} --timeout=60s

# Get the NodePort and Instance IP
NODE_PORT=$(kubectl get svc ${UNIQUE_NAME} -n ${DEVELOPER_ID} -o jsonpath='{.spec.ports[0].nodePort}')
INSTANCE_IP=$(curl -s https://checkip.amazonaws.com)

echo "================================================================="
echo "Deployment successful! Your app is available at:"
echo "http://${INSTANCE_IP}:${NODE_PORT}"
echo "or"
echo "http://${UNIQUE_NAME}.${DEVELOPER_ID}.apps.k3s.company.com"
echo "================================================================="
echo "To view your deployments:"
echo "kubectl get all -n ${DEVELOPER_ID}"
echo ""
echo "To clean up this deployment:"
echo "kubectl delete deployment,service,ingress ${UNIQUE_NAME} -n ${DEVELOPER_ID}"
echo "================================================================="

# Show resource usage
echo "Current namespace resource usage:"
kubectl describe quota -n ${DEVELOPER_ID}