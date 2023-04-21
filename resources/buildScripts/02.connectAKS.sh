#!/bin/bash

echo "Connecting to Azure with SP ${AZ_SP_ID}"
az login --service-principal -u ${AZ_SP_ID} -p ${AZ_SP_SECRET} --tenant ${AZ_TENANT_ID} || exit 1

echo "Retrieving kubeconfig file for cluster ${AKS_CLUSTER_NAME}"
az aks get-credentials --resource-group ${AKS_RESOURCE_GROUP} --name ${AKS_CLUSTER_NAME} --overwrite-existing || exit 1

kubectl get nodes || exit 1
