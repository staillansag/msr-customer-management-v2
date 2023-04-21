#!/bin/bash

echo "Logging in to repository ${DOCKER_REGISTRY_URI}"
docker login -u "${DOCKER_REGISTRY_ID}" -p "${DOCKER_REGISTRY_SECRET}" "${DOCKER_REGISTRY_URI}"  || exit 3

echo "Building tag ${IMAGE_TAG_BASE}"
docker build \
  -t "${IMAGE_TAG_BASE}" . || exit 3

dockerHostName=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1 | tr '[:upper:]' '[:lower:]')

echo "Environment file for testing: ${DOCKERENV_SECUREFILEPATH}"
dockerId=$(docker run --name ${dockerHostName} -d --network sag --env-file ${DOCKERENV_SECUREFILEPATH} "${IMAGE_TAG_BASE}")

echo "Checking availability of http://${dockerHostName}:5555"
max_retry=10
counter=1
until curl -s http://${dockerHostName}:5555
do
   sleep 10
   [[ counter -gt $max_retry ]] && echo "Docker container did not start" && exit 1
   echo "Trying again to access MSR admin URL. Try #$counter"
   ((counter++))
done

echo "Basic sanity check of the generated docker image"
curl -s -o /dev/null --location --request GET "http://${dockerHostName}:5555/customer-management/customers" \
--header 'Authorization: Basic QWRtaW5pc3RyYXRvcjptYW5hZ2U=a' && echo "Test passed" || exit 4 

crtTag="${IMAGE_TAG_BASE}:${IMAGE_MAJOR_VERSION}.${IMAGE_MINOR_VERSION}.${BUILD_BUILDID}"

echo "Tagging ${IMAGE_TAG_BASE} to ${crtTag}"
docker tag "${IMAGE_TAG_BASE}" "${crtTag}"

echo "==================> BUILD_REASON = ${BUILD_REASON}"

echo "Pushing tag ${crtTag}"
docker push "${crtTag}"

if [[ "${BUILD_SOURCEBRANCHNAME}" == "main" ]]; then
  echo "Pushing tag ${IMAGE_TAG_BASE}"
  docker push "${IMAGE_TAG_BASE}"
fi

echo "Logging out"
docker logout "${DOCKER_REGISTRY_URI}"

echo "Push completed"

echo "Cleaning docker container"
docker stop ${dockerId}
docker rm ${dockerId}
