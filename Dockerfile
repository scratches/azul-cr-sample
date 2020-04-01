FROM ubuntu as base
WORKDIR /workspace/jdk
COPY zulu8.44*.tar.gz jdk.tgz
RUN tar -zxf jdk.tgz && mv zulu* zulu && rm jdk.tgz
# && chmod u+s zulu/lib/amd64/criu

FROM  openjdk:8-jdk-alpine as build
WORKDIR /workspace/app
ENV PATH="${PATH}:/workspace/jdk/zulu/bin"
ENV JAVA_HOME=/workspace/jdk/zulu
#COPY target/petclinic.jar app.jar
COPY target/server-*.jar app.jar
RUN mkdir dependency && cd dependency && jar -xf ../*.jar

FROM base as checkpoint
VOLUME /tmp
ENV PATH="${PATH}:/workspace/jdk/zulu/bin"
ENV JAVA_HOME=/workspace/jdk/zulu
WORKDIR /
ARG DEPENDENCY=/workspace/app/dependency
RUN mkdir -p /opt
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
#RUN java -Zcheckpoint -cp app:app/lib/* com.azul.helper.CRMain com.example.ServerApplication
CMD java -Zcheckpoint -XX:CRTrainingCount=3 -cp app:app/lib/* com.azul.helper.CRMain com.example.ServerApplication
#CMD java -Zcheckpoint -XX:CRTrainingCount=3 -cp app:app/lib/* com.azul.helper.CRMain org.springframework.samples.petclinic.PetClinicApplication

#FROM checkpoint
#VOLUME /tmp
#CMD []
#ENTRYPOINT ["sh", "-c", "java -Zrestore ${JAVA_OPTS} -cp app:app/lib/* com.example.ServerApplication ${0} ${@}"]

# Build the base image
# docker build -t spring-demo .
# Create the cache:
# docker run --name spring-checkpoint --privileged spring-demo
# Modify the command
# docker commit -c 'CMD ["sh", "-c", "java -Zrestore -cp app:app/lib/* com.example.ServerApplication"]' spring-checkpoint spring-demo-crac
# Run the app with cache restored
# docker run --rm --privileged spring-demo-crac