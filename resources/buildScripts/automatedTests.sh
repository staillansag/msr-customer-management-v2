 #!/bin/bash

 echo "Microgateway deployment skipped: ${SKIP_MICROGATEWAY}"

if [ "${SKIP_MICROGATEWAY}" = "true" ]
then
  echo "Getting Postman environment file for Production environment (standalone MSR)..."
  if [ ! -f "${POSTMANENVIRONMENTPRODMSR_SECUREFILEPATH}" ]; then
    echo "Secure file path not present: ${POSTMANENVIRONMENTPRODMSR_SECUREFILEPATH}"
    exit 1
  fi

  newman run ./test/newman/CustomerManagementMSR.postman_collection.json \
    -e ${POSTMANENVIRONMENTPRODMSR_SECUREFILEPATH} || exit 8
else
  echo "Getting Postman environment file for Production environment..."
  if [ ! -f "${POSTMANENVIRONMENTPROD_SECUREFILEPATH}" ]; then
    echo "Secure file path not present: ${POSTMANENVIRONMENTPROD_SECUREFILEPATH}"
    exit 1
  fi

  newman run ./test/newman/CustomerManagement.postman_collection.json \
    -e ${POSTMANENVIRONMENTPROD_SECUREFILEPATH} || exit 8
fi
 

