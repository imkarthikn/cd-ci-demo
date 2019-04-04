FROM maven:3-alpine
RUN mkdir -p /pipeline/src
COPY pom.xml /pipeline/

COPY src/ /pipeline/src/

WORKDIR /pipeline/

RUN mvn clean install

EXPOSE 8090

ENTRYPOINT [ "java", "-jar", "/pipeline/target/demo-mindtree.jar"]
