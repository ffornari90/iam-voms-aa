#!/bin/bash
export ROOTDIR=$(git rev-parse --show-toplevel)
if [[ ! -z "${IAM_CERT_URL}" ]]; then
  curl "${IAM_CERT_URL}" -o ${ROOTDIR}/scripts/hostcert.pem
  export SUBJECT=$(docker run --rm -v ${ROOTDIR}/scripts:/root ffornari/openssl x509 -in /root/hostcert.pem -noout -subject | awk -F"subject= " '{print $2}')
  export ISSUER=$(docker run --rm -v ${ROOTDIR}/scripts:/root ffornari/openssl x509 -in /root/hostcert.pem -noout -issuer | awk -F"issuer= " '{print $2}')
  export IAM_FQDN=$(docker run --rm -v ${ROOTDIR}/scripts:/root ffornari/openssl x509 -in /root/hostcert.pem -noout -subject | awk -F'=' '{print $NF}')
  rm -f ${ROOTDIR}/scripts/hostcert.pem
fi
docker build --build-arg VO=${VO_NAME:-test.vo} \
             --build-arg IAM_HOST=${IAM_FQDN:-iam-indigo.cr.cnaf.infn.it} \
             --build-arg HOST_CERT_SUBJECT="${SUBJECT:-\"/DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/OU=CNAF/CN=iam-indigo.cr.cnaf.infn.it\"}" \
             --build-arg HOST_CERT_ISSUER="${ISSUER:-\"/C=NL/O=GEANT Vereniging/CN=GEANT eScience SSL CA 4\"}" \
             --build-arg CLIENT_CERT_URL=${USER_CERT_URL} \
             --build-arg CLIENT_PRIV_KEY=${USER_PRIV_KEY} \
             -f ${ROOTDIR}/voms-client/Dockerfile \
             -t voms-client:latest \
             ${ROOTDIR}/voms-client
