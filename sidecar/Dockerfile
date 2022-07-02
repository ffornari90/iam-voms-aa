FROM centos:7
COPY ./assets/scripts/wait-for-it.sh /
COPY ./assets/conf.d/vomses.template /
COPY ./assets/conf.d/lsc.template /
COPY ./assets/conf.d/voms-ng.conf /
COPY ./assets/conf.d/application.yml /
RUN yum install -y epel-release && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    yum install -y openssl gettext && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    chmod +x /wait-for-it.sh
CMD ["/bin/sh", "-c", "cp /wait-for-it.sh /files \
    && cp /voms-ng.conf /files \
    && cp /application.yml /files \
    && sleep infinity"]
