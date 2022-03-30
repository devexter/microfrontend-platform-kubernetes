#!/bin/bash

DIRECTORY=$(cd `dirname $0` && pwd)

source $DIRECTORY/../../../gcp/set-env.sh

echo "Deploying Mashroom Portal on Kubernetes cluster ${CLUSTER}"

# Determine Portal IP
export PORTAL_IP=`gcloud compute addresses describe portal-global-ip --global --format='get(address)'`
export PORTAL_URL="http://${PORTAL_IP}"

# Set auth on kubectl and docker
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
gcloud auth configure-docker

# Add Service account
kubectl apply -f $DIRECTORY/../list-services-cluster-role.yaml
kubectl apply -f $DIRECTORY/../mashroom-portal-service-account.yaml
kubectl apply -f $DIRECTORY/../mashroom-portal-service-account-role-binding.yaml

# Create deployment
envsub $DIRECTORY/mashroom-portal-deployment_template.yaml $DIRECTORY/mashroom-portal-deployment.yaml
kubectl apply -f $DIRECTORY/mashroom-portal-deployment.yaml

# Create the Service and Ingress
kubectl apply -f $DIRECTORY/../mashroom-portal-service.yaml
kubectl apply -f $DIRECTORY/../mashroom-portal-ingress.yaml

echo "Portal is available at: ${PORTAL_URL} (takes some time after the first deployment)"
