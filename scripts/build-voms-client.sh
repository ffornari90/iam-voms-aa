#!/bin/bash
if [[ ! -z "${IAM_CERT_URL}" ]]; then
  curl "${IAM_CERT_URL}" -o ./hostcert.pem
  export SUBJECT=$(openssl x509 -in ./hostcert.pem -noout -subject | awk -F"subject= " '{print $2}')
  export ISSUER=$(openssl x509 -in ./hostcert.pem -noout -issuer | awk -F"issuer= " '{print $2}')
  export IAM_FQDN=$(openssl x509 -in ./hostcert.pem -noout -subject | awk -F'=' '{print $NF}')
  rm -f ./hostcert.pem
fi
export ROOTDIR=$(git rev-parse --show-toplevel)
docker build --build-arg VO=${VO_NAME:-test.vo} \
             --build-arg IAM_HOST=${IAM_FQDN:-iam-indigo.cr.cnaf.infn.it} \
             --build-arg HOST_CERT_SUBJECT=${SUBJECT:-"/DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/OU=CNAF/CN=iam-indigo.cr.cnaf.infn.it"} \
             --build-arg HOST_CERT_ISSUER=${ISSUER:-"/C=NL/O=GEANT Vereniging/CN=GEANT eScience SSL CA 4"} \
             -f ${ROOTDIR}/voms-client/Dockerfile \
             -t ffornari/voms-client:latest \
             ${ROOTDIR}/voms-client
