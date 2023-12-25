FROM centos:7
ARG VO
ARG IAM_HOST
ARG HOST_CERT_SUBJECT
ARG HOST_CERT_ISSUER
ARG CLIENT_CERT_URL
ARG CLIENT_PRIV_KEY
ENV X509_USER_CERT="/home/user/.globus/usercert.pem"
ENV X509_USER_KEY="/home/user/.globus/userkey.pem"
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
    yum install -y ca-policy-egi-core voms-clients-java gettext \
    python3-pip gfal2-all gfal2-util gfal2-python3 xrootd-client && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    cp /etc/grid-security/certificates/*.pem /etc/pki/ca-trust/source/anchors/ && \
    curl -k "https://ssl-tools.net/certificates/c2826e266d7405d34ef89762636ae4b36e86cb5e.pem" \
    -o /etc/pki/ca-trust/source/anchors/geant-ov-rsa-ca.pem && \
    update-ca-trust && \
    mkdir -p /etc/vomses /etc/grid-security/vomsdir/$VO && \
    envsubst '${VO},${IAM_HOST},${HOST_CERT_SUBJECT}' < /vomses.template > /etc/vomses/$VO && \
    envsubst '${HOST_CERT_SUBJECT},${HOST_CERT_ISSUER}' < /lsc.template > /etc/grid-security/vomsdir/$VO/$IAM_HOST.lsc && \
    groupadd -g 1000 user && \
    useradd -u 1000 -g 1000 user
USER user
RUN mkdir ~/.globus && \
    if [[ ! -z "$CLIENT_CERT_URL" ]]; then curl "${CLIENT_CERT_URL}" -o "${X509_USER_CERT}"; \
    else echo "WARNING"':'" certificate for VOMS client NOT set"'!'; fi && \
    if [[ ! -z "$CLIENT_PRIV_KEY" ]]; then echo $CLIENT_PRIV_KEY | base64 -d | tee "${X509_USER_KEY}"; \
      echo "WARNING"':'" You CANNOT safely push this image to Docker Hub."; \
    else echo "WARNING"':'" private key for VOMS client NOT set"'!'" You can safely push this image to Docker Hub."; fi
CMD ["/bin/sh", "-c", "chmod 600 ${X509_USER_CERT} && chmod 400 ${X509_USER_KEY} && bash"]
