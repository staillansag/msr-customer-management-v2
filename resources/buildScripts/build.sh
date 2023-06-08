#!/bin/bash

echo "Logging in to repository ${DOCKER_REGISTRY_URI}"
docker login -u "${DOCKER_REGISTRY_ID}" -p "${DOCKER_REGISTRY_SECRET}" "${DOCKER_REGISTRY_URI}"  || exit 3

echo "Building tag ${IMAGE_TAG_BASE}"
docker build \
  -t "${IMAGE_TAG_BASE}" . || exit 3

crtTag="${IMAGE_TAG_BASE}:${IMAGE_MAJOR_VERSION}.${IMAGE_MINOR_VERSION}.${BUILD_BUILDID}"

echo "Tagging ${IMAGE_TAG_BASE} to ${crtTag}"
docker tag "${IMAGE_TAG_BASE}" "${crtTag}"

echo "==================> BUILD_REASON = ${BUILD_REASON}"

echo "Pushing tag ${crtTag}"
docker push "${crtTag}"

if [[ "${BUILD_SOURCEBRANCHNAME}" == "master" ]]; then
  echo "Pushing tag ${IMAGE_TAG_BASE}"
  docker push "${IMAGE_TAG_BASE}"
fi

echo "Logging out"
docker logout "${DOCKER_REGISTRY_URI}"

echo "Push completed"

