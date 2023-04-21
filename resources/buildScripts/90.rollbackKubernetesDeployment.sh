#!/bin/bash

kubectl rollout undo deployment/customer-management --to-revision=${ROLLBACK_REVISION}

echo "Waiting for deployment to complete"
kubectl rollout status deployment customer-management --timeout=300s && echo "Deployment complete" || exit 6

echo "Checking service readiness (by making a call to the microgateway metrics endpoint)"
curl -s -o /dev/null --location --request GET "https://customers.sttlab.eu/metrics" && echo "Service is up" || exit 6
