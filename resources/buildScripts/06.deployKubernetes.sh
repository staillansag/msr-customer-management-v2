 #!/bin/bash

echo "Getting the ID of the current revision, in case we have to rollback to it"
rollbackRevision=$(kubectl rollout history deployment/customer-management -o jsonpath='{.metadata.generation}')
echo "##vso[task.setvariable variable=ROLLBACK_REVISION;]${rollbackRevision}"

imageTag="${IMAGE_TAG_BASE}:${IMAGE_MAJOR_VERSION}.${IMAGE_MINOR_VERSION}.${BUILD_BUILDID}"

echo "Deploying new msr image"
sed 's/customer\-management\:latest/customer\-management\:'${imageTag}'/g' ./deployment/kubernetes/01_msr-customer-management_deployment.yaml | kubectl apply -f - || exit 6

echo "Deploying msr service (in case it does not already exist)"
kubectl apply -f ./deployment/kubernetes/02_msr-customer-management_service.yaml || exit 6

echo "Microgateway deployment skipped: ${SKIP_MICROGATEWAY}"

if [ "${SKIP_MICROGATEWAY}" = "true" ]
then
    # If microgateway deployment is skipped, we make the ingress controller point to the msr service
    sed 's/mcgw\-customer\-management/msr\-customer\-management/g' ./deployment/kubernetes/99_ingress.yaml | kubectl apply -f - || exit 6
else
    echo "Deploying microgateway image"
    kubectl apply -f ./deployment/kubernetes/03_mcgw-customer-management_deployment.yaml || exit 6

    echo "Deploying microgateway service"
    kubectl apply -f ./deployment/kubernetes/04_mcgw-customer-management_service.yaml || exit 6

    echo "Deploying ingress"
    kubectl apply -f ./deployment/kubernetes/99_ingress.yaml || exit 6
fi

echo "Waiting for deployment to complete"
kubectl rollout status deployment customer-management --timeout=300s && echo "Deployment complete" || exit 6

echo "Checking service readiness (by making a call to the microgateway metrics endpoint)"
curl -s -o /dev/null --location --request GET "https://customers.sttlab.eu/metrics" && echo "Service is up" || exit 6
