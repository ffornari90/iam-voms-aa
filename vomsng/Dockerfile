FROM indigoiam/voms-aa:latest as source-layer
FROM openjdk:11
WORKDIR /app
COPY ./assets/scripts/wait-for-it.sh /
COPY --from=source-layer /app /app
RUN chmod +x /wait-for-it.sh
COPY ./assets/conf.d/application.yml /app/resources/
EXPOSE 15000
CMD java -cp @/app/jib-classpath-file it.infn.mw.voms.VomsService
