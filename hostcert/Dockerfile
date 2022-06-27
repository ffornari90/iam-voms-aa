FROM centos:7
COPY ./assets/certs/hostkey.pem /etc/ssl/certs/
COPY ./assets/certs/hostcert.pem /etc/ssl/certs/
COPY ./assets/scripts/wait-for-it.sh /
RUN yum install -y epel-release && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN yum install -y netcat && \
    yum clean all && \
    rm -rf /var/cache/yum
RUN chmod +x /wait-for-it.sh
EXPOSE 8085
CMD nc -l 8085
