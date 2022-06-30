FROM alpine:latest
COPY ./assets/scripts/wait-for-it.sh /
COPY ./assets/conf.d/nginx.conf /
COPY ./assets/conf.d/voms-ng.conf /
COPY ./assets/conf.d/application.yml /
RUN chmod +x /wait-for-it.sh
CMD ["/bin/sh", "-c", "cp /wait-for-it.sh /opt/bin \
    && cp /nginx.conf /opt/bin \
    && cp /voms-ng.conf /opt/bin \
    && cp /application.yml /opt/bin \
    && sleep infinity"]
