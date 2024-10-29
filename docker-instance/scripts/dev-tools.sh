#!/bin/bash

# dev-tools.sh
# Usage: ./dev-tools.sh <developer-id> <command>

if [ "$#" -lt 2 ]; then
    echo "Usage: ./dev-tools.sh <developer-id> <command>"
    echo "Commands:"
    echo "  list     - List all your deployments"
    echo "  clean    - Remove all your deployments"
    echo "  quota    - Show your resource usage"
    echo "  logs     - Show logs for a deployment"
    echo "Example: ./dev-tools.sh john list"
    exit 1
fi

DEVELOPER_ID=$1
COMMAND=$2

case $COMMAND in
    "list")
        echo "Listing all resources for ${DEVELOPER_ID}:"
        kubectl get all -n ${DEVELOPER_ID}
        ;;
    "clean")
        echo "Cleaning up all deployments for ${DEVELOPER_ID}..."
        kubectl delete deployment,service,ingress --all -n ${DEVELOPER_ID}
        ;;
    "quota")
        echo "Resource quota usage for ${DEVELOPER_ID}:"
        kubectl describe quota -n ${DEVELOPER_ID}
        ;;
    "logs")
        if [ "$#" -ne 3 ]; then
            echo "Please specify deployment name"
            echo "Usage: ./dev-tools.sh ${DEVELOPER_ID} logs <deployment-name>"
            exit 1
        fi
        DEPLOYMENT=$3
        kubectl logs deployment/${DEPLOYMENT} -n ${DEVELOPER_ID}
        ;;
    *)
        echo "Unknown command: ${COMMAND}"
        exit 1
        ;;
esac