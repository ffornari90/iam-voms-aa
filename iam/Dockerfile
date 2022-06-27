FROM indigoiam/nginx:latest
COPY ./assets/scripts/wait-for-it.sh /
COPY ./assets/conf.d/mysite.template /etc/nginx/conf.d/
RUN chmod +x /wait-for-it.sh
EXPOSE 80 443
CMD nginx -g 'daemon off;'
