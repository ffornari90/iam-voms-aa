FROM centos:7
COPY ./assets/scripts/wait-for-it.sh /
COPY ./assets/scripts/prepare-x5c-jwk.sh /
COPY ./assets/conf.d/vomses.template /
COPY ./assets/conf.d/lsc.template /
COPY ./assets/conf.d/voms-ng.conf /
COPY ./assets/conf.d/application.yml /
COPY ./assets/conf.d/iam-application.yml /
RUN yum install -y epel-release && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    yum install -y openssl gettext jq netcat java-11-openjdk-headless java-11-openjdk-devel git maven && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    chmod +x /wait-for-it.sh
CMD ["/bin/sh", "-c", "cp /wait-for-it.sh /scripts \
    && cp /prepare-x5c-jwk.sh /scripts \
    && cp /voms-ng.conf /conf.d \
    && cp /application.yml /conf.d \
    && cp /iam-application.yml /conf.d \
    && update-alternatives --set java \"$(update-alternatives --list | grep -w jre_11 | awk '{print $3}')/bin/java\" \
    && update-alternatives --set javac \"$(update-alternatives --list | grep -w jre_11 | awk '{print $3}')/bin/javac\" \
    && sleep infinity"]
