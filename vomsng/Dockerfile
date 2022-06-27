FROM maven:3-jdk-11
ENV VOMS_NG_JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Xdebug -Xrunjdwp:server=y,transport=dt_socket,suspend=n,address=1044"
ENV VOMS_AA_VERSION="0.5.0"
COPY ./assets/scripts/wait-for-it.sh /
COPY ./assets/conf.d/cnaf-mirror-settings.xml /root/.m2/settings.xml
RUN git clone https://baltig.infn.it/aceccant/voms-aa.git /voms-aa
WORKDIR /voms-aa
RUN chmod +x /wait-for-it.sh && \
    mvn -Pnexus package && \
    mv target/voms-aa-${VOMS_AA_VERSION}.jar voms-aa.jar && \
    rm -rf target /root/.m2/* && \
    mkdir config
COPY ./assets/conf.d/application.yml /voms-aa/config/
EXPOSE 15000
CMD java -XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport ${VOMS_NG_JAVA_OPTS} -jar voms-aa.jar
