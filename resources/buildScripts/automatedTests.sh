 #!/bin/bash

sed 's#REPLACEME_API_ENDPOINT#'${API_ENDPOINT}'#g' ./resources/test/newman/CustomerManagement-environment-template.json | sed 's#REPLACEME_API_KEY#'${API_KEY}'#g' > env

cat env

newman run ./resources/test/newman/CustomerManagement.postman_collection.json \
  -e env || exit 8

 

