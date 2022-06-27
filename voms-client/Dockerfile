FROM centos:7
RUN yum install -y epel-release && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    echo $'[EGI-trustanchors]\n\
name=EGI-trustanchors\n\
baseurl=http://repository.egi.eu/sw/production/cas/1/current/\n\
gpgcheck=0\n\
enabled=1' | tee /etc/yum.repos.d/ca.repo
RUN yum install -y ca-policy-egi-core voms-clients-java && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN cp /etc/grid-security/certificates/*.pem /etc/pki/ca-trust/source/anchors/ && \
    curl -k "https://ssl-tools.net/certificates/c2826e266d7405d34ef89762636ae4b36e86cb5e.pem" \
    -o /etc/pki/ca-trust/source/anchors/geant-ov-rsa-ca.pem && \
    update-ca-trust && \
    mkdir -p /etc/vomses /etc/grid-security/vomsdir/test.vo && \
    echo '"test.vo" "iam-indigo.cr.cnaf.infn.it" "15000" "/DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/OU=CNAF/CN=iam-indigo.cr.cnaf.infn.it" "test.vo"' \
    | tee /etc/vomses/test.vo && \
    echo $'/DC=org/DC=terena/DC=tcs/C=IT/ST=Roma/O=Istituto Nazionale di Fisica Nucleare/OU=CNAF/CN=iam-indigo.cr.cnaf.infn.it\n\
/C=NL/O=GEANT Vereniging/CN=GEANT eScience SSL CA 4' | tee /etc/grid-security/vomsdir/test.vo/iam-indigo.cr.cnaf.infn.it.lsc
CMD ["/bin/bash"]
