FROM storm2/ngx-voms:latest
COPY ./assets/scripts/wait-for-it.sh /
RUN mkdir -p /vomsdir/test.vo && \
    chmod +x /wait-for-it.sh
COPY ./assets/vomsdir/test.vo/iam-indigo.cr.cnaf.infn.it.lsc /vomsdir/test.vo/
COPY ./assets/conf.d/nginx.conf /home/build/local/openresty/nginx/conf/
COPY ./assets/conf.d/voms-ng.conf /etc/nginx/conf.d/mysite.template
EXPOSE 443
CMD /home/build/local/openresty/nginx/sbin/nginx -g 'daemon off;'
