 #!/bin/bash

echo "Getting Postman environment file for Production environment..."
if [ ! -f "${POSTMANENVIRONMENTPROD_SECUREFILEPATH}" ]; then
  echo "Secure file path not present: ${POSTMANENVIRONMENTPROD_SECUREFILEPATH}"
  exit 1
fi

newman run ./resources/test/newman/CustomerManagement.postman_collection.json \
  -e ${POSTMANENVIRONMENTPROD_SECUREFILEPATH} || exit 8

 

