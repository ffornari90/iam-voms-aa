FROM centos:7
ARG VO
ARG IAM_HOST
ARG HOST_CERT_SUBJECT
ARG HOST_CERT_ISSUER
COPY ./assets/conf.d/vomses.template /
COPY ./assets/conf.d/lsc.template /
RUN yum install -y epel-release && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    echo $'[EGI-trustanchors]\n\
name=EGI-trustanchors\n\
baseurl=http://repository.egi.eu/sw/production/cas/1/current/\n\
gpgcheck=0\n\
enabled=1' | tee /etc/yum.repos.d/ca.repo && \
    yum install -y ca-policy-egi-core voms-clients-java gettext && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    cp /etc/grid-security/certificates/*.pem /etc/pki/ca-trust/source/anchors/ && \
    curl -k "https://ssl-tools.net/certificates/c2826e266d7405d34ef89762636ae4b36e86cb5e.pem" \
    -o /etc/pki/ca-trust/source/anchors/geant-ov-rsa-ca.pem && \
    update-ca-trust && \
    mkdir -p /etc/vomses /etc/grid-security/vomsdir/$VO && \
    envsubst '${VO},${IAM_HOST},${HOST_CERT_SUBJECT}' < /vomses.template > /etc/vomses/$VO && \
    envsubst '${HOST_CERT_SUBJECT},${HOST_CERT_ISSUER}' < /lsc.template > /etc/grid-security/vomsdir/$VO/$IAM_HOST.lsc
CMD ["/bin/bash"]
