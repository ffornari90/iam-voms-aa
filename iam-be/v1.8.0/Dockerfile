FROM indigoiam/iam-login-service:v1.8.0.sb25.111221
ENV IAM_JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Xdebug -Xrunjdwp:server=y,transport=dt_socket,suspend=n,address=1044 -Dspring.profiles.active=prod,registration"
COPY ./assets/scripts/wait-for-it.sh /
RUN chmod +x /wait-for-it.sh
WORKDIR /indigo-iam
EXPOSE 8080
CMD java ${IAM_JAVA_OPTS} org.springframework.boot.loader.WarLauncher
