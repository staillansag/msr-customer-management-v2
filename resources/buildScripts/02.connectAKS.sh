#!/bin/bash

echo "Connecting to Azure with SP ${AZ_SP_ID}"
az login --service-principal -u ${AZ_SP_ID} -p ${AZ_SP_SECRET} --tenant ${AZ_TENANT_ID}

echo "Retrieving kubeconfig file for cluster ${CLUSTER_NAME}"
az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --overwrite-existing

kubectl get nodes || exit 1
