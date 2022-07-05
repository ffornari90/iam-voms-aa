#!/bin/bash
export ROOTDIR=$(git rev-parse --show-toplevel)
if [[ ! -z "${IAM_CERT_URL}" ]]; then
  curl "${IAM_CERT_URL}" -o ${ROOTDIR}/scripts/hostcert.pem
  export SUB_CMD="openssl x509\
                  -in /root/hostcert.pem\
                  -noout -subject\
                  | cut -d' ' -f2-"
  export ISS_CMD="openssl x509\
                  -in /root/hostcert.pem\
                  -noout -issuer\
                  | cut -d' ' -f2-"
  export SUBJECT="$(docker run -v ${ROOTDIR}/scripts:/root\
                              --rm\
                              --entrypoint bash\
                              ffornari/openssl\
                              -c\
                              "${SUB_CMD}")"
  export ISSUER="$(docker run -v ${ROOTDIR}/scripts:/root\
                              --rm\
                              --entrypoint bash\
                              ffornari/openssl\
                              -c\
                              "${ISS_CMD}")"
  export IAM_FQDN="$(echo $SUBJECT | awk -F'=' '{print $NF}')"
  rm -f ${ROOTDIR}/scripts/hostcert.pem
fi
docker build --build-arg VO=${VO_NAME:-test.vo} \
             --build-arg IAM_HOST=${IAM_FQDN} \
             --build-arg HOST_CERT_SUBJECT="${SUBJECT}" \
             --build-arg HOST_CERT_ISSUER="${ISSUER}" \
             --build-arg CLIENT_CERT_URL="${USER_CERT_URL}" \
             --build-arg CLIENT_PRIV_KEY="${USER_PRIV_KEY}" \
             -f ${ROOTDIR}/voms-client/Dockerfile \
             -t voms-client:latest \
             ${ROOTDIR}/voms-client
