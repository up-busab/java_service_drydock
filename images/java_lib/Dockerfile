ARG BUILD_CONTEXT_IMAGE
ARG LIB_NAME=your-artifactId-from-pom
ARG M2_PATH=/root/.m2/repository

#bASe layer sets up local m2 and adds source
FROM $BUILD_CONTEXT_IMAGE AS base_build
ARG LIB_NAME
ARG M2_PATH
WORKDIR /lib_builder

#bring in the source, delete all hidden files
COPY pom.xml .
COPY src ./src 
RUN find -type f -name ".*" -delete
RUN cp /build_context/m2_jar_installer.sh /lib_builder/m2_jar_installer.sh

#RUN --mount=type=cache,target=${M2_PATH} mvn install -DskipTests
RUN --mount=type=cache,target=/root/.m2/repository mvn package -DskipTests
#RUN mv target/${LIB_NAME}.jar lib/ ${LIB_NAME}.jar
#RUN mvn org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file -Dfile=target/${LIB_NAME}.jar

ENTRYPOINT ["/lib_builder/m2_jar_installer.sh", "/lib_builder/target", "/lib_builder/m2/repository"]
