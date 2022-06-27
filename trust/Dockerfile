FROM alpine:latest
RUN mkdir -p /etc/grid-security/certificates tgz
EXPOSE 8086
CMD wget http://repository.egi.eu/sw/production/cas/1/current/tgz/ && \
    for tgz in $(cat index.html | awk -F'"' '{print $2}' | grep tar.gz); do wget http://repository.egi.eu/sw/production/cas/1/current/tgz/$tgz -O tgz/$tgz; done && \
    for tgz in $(ls tgz/); do tar xzf tgz/$tgz --strip-components=1 -C /etc/grid-security/certificates; done && \
    nc -l -p 8086
