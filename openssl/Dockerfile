FROM centos:7
RUN yum install -y epel-release && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    yum install -y openssl && \
    yum clean all && \
    rm -rf /var/cache/yum
ENTRYPOINT ["openssl"]
