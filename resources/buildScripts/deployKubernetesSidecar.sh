 #!/bin/bash

echo "Getting the ID of the current revision, in case we have to rollback to it"
rollbackRevision=$(kubectl rollout history deployment/customer-management -o jsonpath='{.metadata.generation}')
echo "##vso[task.setvariable variable=ROLLBACK_REVISION;]${rollbackRevision}"

echo "(Re)Creating environment specific Kubernetes config map"
kubectl delete configmap environment-config
kubectl create configmap environment-config \
	 --from-literal=apiGatewayUrl=${API_GATEWAY_URL} \
	 --from-literal=wmioIntegrationUrl=${WMIO_INT_URL} \
         --from-literal=domainName=${DOMAIN_NAME} \
         --from-literal=databaseServerName=${DB_SERVERNAME} \
         --from-literal=databaseServerPort=${DB_PORT} \
         --from-literal=databaseName=${DB_NAME} \
		 --from-literal=jndiAliasProviderUrl=${JNDI_ALIAS_PROVIDER_URL} || exit 6

echo "(Re)Creating environment specific Kubernetes secrets"
kubectl delete secret generic environment-secrets
kubectl create secret generic environment-secrets \
	 --from-literal=databaseUser=${DB_USER} \
	 --from-literal=databasePassword=${DB_PASSWORD} \
         --from-literal=wmioIntegrationUser=${IO_INT_USER} \
         --from-literal=wmioIntegrationPassword=${IO_INT_PASSWORD} \
         --from-literal=apiGatewayUser=${API_GATEWAY_USER} \
         --from-literal=apiGatewayPassword=${API_GATEWAY_PASSWORD}

imageTag="${IMAGE_TAG_BASE}:${IMAGE_MAJOR_VERSION}.${IMAGE_MINOR_VERSION}.${BUILD_BUILDID}"

echo "Deploying new msr image"
sed 's/\:latest/\:'${IMAGE_MAJOR_VERSION}.${IMAGE_MINOR_VERSION}.${BUILD_BUILDID}'/g' ./resources/deployment/kubernetes-side-car/01_msr-customer-management_deployment.yaml | kubectl apply -f - || exit 6

echo "Deploying msr service (in case it does not already exist)"
kubectl apply -f ./resources/deployment/kubernetes-side-car/02_msr-customer-management_service.yaml || exit 6

echo "Deploying ingress"
kubectl apply -f ./resources/deployment/kubernetes/99_ingress.yaml || exit 6

echo "Waiting for deployment to complete"
kubectl rollout status deployment customer-management --timeout=300s && echo "Deployment complete" || exit 6

echo "Checking service readiness (by making a call to the microgateway metrics endpoint)"
curl --location --request GET "https://customers.sttlab.eu/metrics" || exit 6
